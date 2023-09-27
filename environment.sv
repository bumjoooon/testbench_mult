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
