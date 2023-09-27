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


