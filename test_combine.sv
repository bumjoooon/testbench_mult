module mult(mult_if _if);

assign _if.y = _if.a * _if.b;

endmodule

class generator;
   int loop = 10;
   event drv_done;
   mailbox drv_mbx;

   task run();
      for (int i =0; i < loop ; i++) begin
         Packet item = new;
         item.randomize();
         $display ("T=%0t [Generator] Loop:%0d/%0d create next item", $time, i+1, loop);
         drv_mbx.put(item);
         $display ("T=%0t [Generator] Wait for driver to be done", $time);
         @(drv_done);
      end
   endtask
endclass

class monitor;
   virtual mult_if m_adder_vif;
   virtual clk_if m_adder_vif;

   mailbox scb_mbx;

   task run();
      $display ("T=%ot [Monitor] starting ...", $time);

      forever begin
         Packet m_pkt = new();

         @(posedge m_clk_vif.tb_clk);
         
         #1;
            m_pkt.a = m_mult_vif.a;
            m_pkt.b = m_mult_vif.b;
            m_pkt.mult = m_mult_vif.mult;
            m_pkt.print("Monitor");

            scb_mbx.put(m_pkt);

         end
      endtask
   endclass

class test;
   env e0;
   mailbox drv_mbx;

   function new();
      drv_mbx = new();
      e0 = new;
   endfunction

   virtual task run();
      e0.d0.drv_mbx = drv_mbx;
      e0.run();
   endtask
endclass

module tb;
mult_if m_mult_if();
my_mult u0 (m_mult_if);

initial begin
   test t0;

   t0 = new;
   t0.e0.m_mult_vif = m_mult_if;
   t0.run();

   #50 $finish
end
endmodule


class driver;
virtual mult_if m_mult_vif;
virtual clk_if m_clk_vif;
event drv_done;
mailbox drv_mbx;

task run();
   $display ("T=%0t [Driver] start, $time);

   forever begin
      Packet item;

      $display ("T=%0t [Driver] waiting for item ...", $time);
      drv_mbx.get(item);
      
      @(posedge m_clk_vif.tb_clk);
         item.print("Driver");
         m_mult_vif.a <= item.a;
         m_mult_vif.b <= item.b;
         ->drv_done;
      end
   endtask
endclass

class env;
  generator 		g0; 			// Generate transactions
  driver 			d0; 			// Driver to design
  monitor 			m0; 			// Monitor from design
  scoreboard 		s0; 			// Scoreboard connected to monitor
  mailbox 			scb_mbx; 		// Top level mailbox for SCB <-> MON
  virtual mult_if 	m_mult_vif; 	// Virtual interface handle

  event drv_done;
  mailbox drv_mbx;

  function new();
     d0 = new;
     m0 = new;
     s0 = new;
     scb_mbx = new();
     g0 = new;
     drv_mbx = new;
  endfunction

  virtual task run();
     // Connect virtual interface handles
     d0.m_mult_vif = m_mult_vif;
     m0.m_mult_vif = m_mult_vif;

     // Connect mailboxes between each component
     d0.drv_mbx = drv_mbx;
     g0.drv_mbx = drv_mbx;

     m0.scb_mbx = scb_mbx;
     s0.scb_mbx = scb_mbx;

     // Connect event handles
     d0.drv_done = drv_done;
     g0.drv_done = drv_done;

     fork
        s0.run();
        d0.run();
        m0.run();
        g0.run();
     join_any
  endtask
endclass

interface mul_if;

    logic [3:0] a;

    logic [3:0] b;

    logic [7:0] y;

endinterface

class scoreboard;
   mailbox scb_mbx;

   task run();
      forever begin
         Packet item, ref_item;
         scb_mbx.get(item);
         item.print("Scoreboard");

         ref_item = new();
         ref_item.copy(item);

         ref_item.mult = ref_item.a * ref_item.b;

         if (ref_item.carry != item.carry) begin
            $display("[%0t] Scoreboard Error! Carry mismatch ref_item=0x%0h item=0x%0h", $time, ref_item.carry, item.carry);
         end 
         else begin
            $display("[%0t] Scoreboard Pass! Carry match ref_item=0x%0h item=0x%0h", $time, ref_item.carry, item.carry);
         end

         if (ref_item.mult != item.mult) begin
            $display("[%0t] Scoreboard Error! Multiplier mismatch ref_item=0x%0h item=0x%0h", $time, ref_item.mult, item.mult);
         end
         else  begin
            $display("[%0t] Scoreboard Pass! Multiplier match ref_item=0x%0h item=0x%0h", $time, ref_item.mult, item.mult);
         end
      end
   endtask
endclass

class Packet;
   rand bit rstn;
   rand bit[7:0] a;
   rand bit[7:0] b;

   bit [7:0] mult;

   function void print(string tag="");
      $display ( "T=%0t %s a=0x%0h b=0x%0h mult=0x%0h", $time, tag, a, b, mult);
   endfunction

   function void copy(Packet tmp);
      this.a = tmp.a;
      this.b = tmp.b;
      this.rstn = tmp.rstn;
      this.mult = tmp.mult;
   endfunction

endclass


