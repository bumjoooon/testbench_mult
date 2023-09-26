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
