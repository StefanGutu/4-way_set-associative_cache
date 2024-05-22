
module control(
    input clk,
    input rst,
    input write,
    input read,
    input hit_or_miss,
    input space_in_lru,
    input bgn,
    output reg c0,c1,c2,c3,c4,c5,c6,c7
);

reg [3:0] nxt_state,state_reg;

parameter IDLE =            4'b0000;
parameter GET_ADDRESS =     4'b0001;
parameter READ =            4'b0010;
parameter WRITE =           4'b0011;
parameter READ_MISS =       4'b0100;
parameter READ_HIT =        4'b0101;
parameter WRITE_MISS =      4'b0110;
parameter WRITE_HIT =       4'b0111;
parameter CHECK =           4'b1000;
parameter EVICT =           4'b1001;
parameter FIN =             4'b1010;
parameter READ2 =           4'b1011;
parameter WRITE2 =          4'b1100;



always @(posedge clk,negedge rst) begin

    if(rst) begin
        state_reg <= IDLE;
        {c0, c1, c2, c3, c4, c5, c6, c7} <= 8'b0;
    end
    else begin
        state_reg <= nxt_state;
    end

end


always @(*) begin
    nxt_state = state_reg;
    case(state_reg)
        IDLE : begin
            if(bgn == 1'b0)begin
                nxt_state <= IDLE;
            end
            else begin
                nxt_state <= GET_ADDRESS;
            end
        end
        GET_ADDRESS : begin
            if(read == 1'b1) begin
                nxt_state <= READ;
            end
            else if(write == 1'b1) begin
                nxt_state <= WRITE;
            end
            else begin
                nxt_state <= GET_ADDRESS;
            end
        end
        READ : begin
            nxt_state <= READ2;
        end
        READ2 : begin
            if(hit_or_miss == 1'b1) begin
                nxt_state <= READ_HIT;
            end
            else if(hit_or_miss == 1'b0) begin
                nxt_state <= READ_MISS;
                
            end
        end
        WRITE : begin
            nxt_state <= WRITE2;
        end
        WRITE2 : begin
            if(hit_or_miss == 1'b1) begin
                nxt_state <= WRITE_HIT;
            end
            else if(hit_or_miss == 1'b0) begin
                nxt_state <= WRITE_MISS;
            end
        end
        READ_HIT : begin
            nxt_state <= IDLE;
        end
        WRITE_HIT : begin
            nxt_state <= IDLE;
        end
        WRITE_MISS : begin
            nxt_state <= CHECK;
        end
        READ_MISS : begin
            nxt_state <= CHECK;
        end
        CHECK : begin 
            if(space_in_lru == 1'b0) begin
                nxt_state <= FIN;
            end
            if(space_in_lru == 1'b1) begin
                nxt_state <= EVICT;
            end
        end
        EVICT : begin
            nxt_state <= FIN;
        end
        FIN : begin
            nxt_state <= IDLE;
        end

    endcase
end


always @(posedge clk,posedge rst) begin
    {c0, c1, c2, c3, c4, c5, c6, c7} <= 8'b0;

    case(nxt_state)
        GET_ADDRESS : begin
            c0 <= 1'b1;
        end
        READ : begin
            c1 <= 1'b1;
        end
        WRITE : begin
            c2 <= 1'b1;
        end
        READ2 : begin
            c1 <= 1'b1;
        end
        WRITE2 : begin
            c2 <= 1'b1;
        end
        READ_HIT : begin
            c1 <= 1'b1;
            c3 <= 1'b1;
        end
        WRITE_HIT : begin
            c2 <= 1'b1;
        end
        READ_MISS : begin
            c1 <= 1'b1;
            c4 <= 1'b1;
            
        end
        WRITE_MISS : begin
            c2 <= 1'b1;
            c4 <= 1'b1;
        end
        CHECK : begin
            c5 <= 1'b1;
        end
        EVICT : begin
            c7 <= 1'b1;
        end
        FIN : begin
            c6 <= 1'b1;
        end


    endcase
end

endmodule


//------------------------------------------------------------------------------------------------------------------------------------------------------------

module struct(
    input clk,
    input rst,
    input bgn,
    input write,
    input read,
    input [511:0] data,
    input [31:0] address,
    output [511:0] outbus,
    output reg t0,t1,t2,t3,t4,t5,t6,t7,
    output reg hit_bar,
    output reg [3:0] and_val
);


    reg hit;
    reg space;
    wire temp_hit;
    wire temp_space;
    wire temp_ask;
    wire [3:0] temp_and;

    wire c0,c1,c2,c3,c4,c5,c6,c7;


    control control_i(  .clk(clk),.rst(rst),.bgn(bgn),.write(write),.read(read),.hit_or_miss(temp_hit),.space_in_lru(temp_space),
                        .c0(c0),.c1(c1),.c2(c2),.c3(c3),.c4(c4),.c5(c5),.c6(c6),.c7(c7));

    cache cache_i(  .clk(clk),.rst(rst),.data(data),.address(address),
                    .c0(c0),.c1(c1),.c2(c2),.c3(c3),.c4(c4),.c5(c5),.c6(c6),.c7(c7),
                    .hit_or_miss(temp_hit),.ask_for_data(temp_ask),.space_in_lru(temp_space),.outbus(outbus),.and_val(temp_and));

    always @(*) begin
        hit = temp_hit;
        space = temp_space;
        t0 = c0;
        t1 = c1;
        t2 = c2;
        t3 = c3;
        t4 = c4;
        t5 = c5;
        t6 = c6;
        t7 = c7;
        hit_bar = temp_hit;
        and_val = temp_and;
    end

endmodule


