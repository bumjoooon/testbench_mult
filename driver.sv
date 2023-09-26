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
