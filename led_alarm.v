module alarm (
    input       clk                 ,
    input       rst_n               ,
    input       rw_done             ,
    input       rw_result           ,     
    
    output      led
);
/*-----------------led----------------*/ 
 always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        led <= 1'd0;
    end
    else if (rw_done) begin
        if (rw_result) begin
            led <= 1'd1;
        end
        else if (!rw_done) begin
            if (cnt_500ms == time_500ms - 1) begin
                led <= ~led;
            end            
        end           
    end
 end  
/*-----------------cnt_500ms----------------*/ 
 parameter time_500ms = 25_000_000; 
 reg [24:0] cnt_500ms;
 always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cnt_500ms <= 25'd0;
    end
    else if (cnt_500ms == time_500ms - 1) begin
        cnt_500ms <= 25'd0;
    end
    else 
        cnt_500ms <= cnt_500ms + 25'd1;
 end
endmodule