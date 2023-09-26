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


