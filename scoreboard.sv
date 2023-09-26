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

