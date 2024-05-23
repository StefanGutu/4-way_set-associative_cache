module cache(
    input clk,
    input rst,
    input c0,c1,c2,c3,c4,c5,c6,c7,
    input [31:0] address,
    input [511:0] data,
    output reg hit_or_miss,
    output reg ask_for_data,
    output reg [3:0] and_val,
    output reg space_in_lru,
    output reg [3:0] dirty_bit,
    output reg [511:0] outbus 
);

    //cache size data
    reg [511:0] cache_size_data [511:0];
    //cache tag
    reg [18:0] cache_tag [511:0];
    //cache valid bit
    reg [511:0] cache_valid_bit;
    //cache dirty bit
    reg [3:0] cache_dirty_bit [127:0];


    //adresa
    reg [18:0] tag;
    reg [6:0] index;
    reg [5:0] offset;


    //LRU
    reg [11:0] lru [127:0];
    integer i;

    //temp values
    reg [511:0] data_from_cache;
    reg [3:0] temp_tag;
    reg [3:0] temp_and_values;
    reg temp_hit;
    reg [1:0] pos_for_new_data;


    //divide the address to make it easier for us to work with index and tag
    always @(posedge clk,negedge rst) begin
        if(c0 == 1'b1) begin
            tag <= address[31:13];
            index <= address[12:6];
            offset <= address[5:0];
            
        end
    end


    always @(posedge clk,negedge rst) begin

        //tag for set 4
        if(tag == cache_tag[index]) begin
            temp_tag[0] <= 1'b1;
        end
        else begin
            temp_tag[0] <= 1'b0;
        end
        //tag for set 3
        if(tag == cache_tag[128+index]) begin
            temp_tag[1] <= 1'b1;
        end
        else begin
            temp_tag[1] <= 1'b0;
        end
        //tag for set 2
        if(tag == cache_tag[2*128+index]) begin
            temp_tag[2] <= 1'b1;
        end
        else begin
            temp_tag[2] <= 1'b0;
        end
        //tag for set 1
        if(tag == cache_tag[3*128+index]) begin
            
            temp_tag[3] <= 1'b1;
        end
        else begin
            temp_tag[3] <= 1'b0;
        end

        //AND operations between comparator and valid
        temp_and_values[3] <= temp_tag[3] && cache_valid_bit[3*128+index];
        temp_and_values[2] <= temp_tag[2] && cache_valid_bit[2*128+index];
        temp_and_values[1] <= temp_tag[1] && cache_valid_bit[128+index];
        temp_and_values[0] <= temp_tag[0] && cache_valid_bit[index];

         
        //OR operation between AND gates
        temp_hit <= temp_and_values[0] || temp_and_values[1] || temp_and_values[2] || temp_and_values[3];


        //MUX 4:1
        if(temp_and_values[3] == 1'b1) begin
            data_from_cache <= cache_size_data[3*128+index][511:0];
        end
        if(temp_and_values[2] == 1'b1) begin
            data_from_cache <= cache_size_data[2*128+index][511:0];
            
        end
        if(temp_and_values[1] == 1'b1) begin
            data_from_cache <= cache_size_data[128+index][511:0];
            
        end
        if(temp_and_values[0] == 1'b1) begin
            data_from_cache <= cache_size_data[index][511:0]; 
        end
        
    end

    always @(posedge clk,negedge rst) begin
        hit_or_miss <= 1'b0;

        if(rst) begin

            cache_valid_bit <= 512'b0;

            for (i = 0; i < 128; i = i + 1) begin
                lru[i] <= 12'b100100100100;
                   
            end
        end
        else begin
            if(c1 == 1'b1) begin //read


                if(temp_hit == 4'b0) begin
                    hit_or_miss <= 1'b0;
                end
                else begin
                    hit_or_miss <= 1'b1;

                    //for dirty bit when you get the second hit from the same data
                    //set1
                    if(temp_and_values[3] == 1'b1 && cache_dirty_bit[index][3] == 1'b0) begin
                        cache_dirty_bit[index][3] <= 1'b1;
                    end
                    //set2
                    if(temp_and_values[2] == 1'b1 && cache_dirty_bit[index][2] == 1'b0) begin
                        cache_dirty_bit[index][2] <= 1'b1;               
                    end
                    //set3
                    if(temp_and_values[1] == 1'b1 && cache_dirty_bit[index][1] == 1'b0) begin
                        cache_dirty_bit[index][1] <= 1'b1;
                    end
                    //set4
                    if(temp_and_values[0] == 1'b1 && cache_dirty_bit[index][0] == 1'b0) begin
                        cache_dirty_bit[index][0] <= 1'b1;
                    end
                end

                dirty_bit <= cache_dirty_bit[index];

                if(c3 == 1'b1) begin
                    outbus <= data_from_cache;
                end

                and_val <= temp_and_values; // shows in which set was stored data
            end
            if(c2 == 1'b1) begin //write
         
                if(temp_hit == 4'b0) begin
                    hit_or_miss <= 1'b0;
                end
                else begin
                    hit_or_miss <= 1'b1;

                    //for dirty bit when you get the second hit from the same data 
                    //and when you need to send data to the main memory
                    //set1
                    if(temp_and_values[3] == 1'b1 && cache_dirty_bit[index][3] == 1'b0 && c3 == 1'b1) begin
                        cache_dirty_bit[index][3] <= 1'b1;
                        outbus <= data_from_cache;
                    end
                    //set2
                    if(temp_and_values[2] == 1'b1 && cache_dirty_bit[index][2] == 1'b0 && c3 == 1'b1) begin
                        cache_dirty_bit[index][2] <= 1'b1;
                        outbus <= data_from_cache;               
                    end
                    //set3
                    if(temp_and_values[1] == 1'b1 && cache_dirty_bit[index][1] == 1'b0 && c3 == 1'b1) begin
                        cache_dirty_bit[index][1] <= 1'b1;
                        outbus <= data_from_cache;
                    end
                    //set4
                    if(temp_and_values[0] == 1'b1 && cache_dirty_bit[index][0] == 1'b0 && c3 == 1'b1) begin
                        cache_dirty_bit[index][0] <= 1'b1;
                        outbus <= data_from_cache;
                    end
                    dirty_bit <= cache_dirty_bit[index];
                end

                and_val <= temp_and_values;// shows in which set was stored data
                
            end
            if(c6 == 1'b1) begin //Load the date into the cache
                

                if(pos_for_new_data == 2'b11) begin
                    lru[index][11:9] <= 3'b000;
                    cache_dirty_bit[index][3] <= 1'b0;
                    cache_size_data[3*128+index] <= data;
                    cache_tag[3*128+index] <= tag;
                    cache_valid_bit[3*128+index] <= 1'b1;
                end
                else if(pos_for_new_data == 2'b10) begin
                    lru[index][8:6] <= 3'b000;
                    cache_dirty_bit[index][2] <= 1'b0;
                    cache_size_data[2*128+index] <= data;
                    cache_tag[2*128+index] <= tag;
                    cache_valid_bit[2*128+index] <= 1'b1;
                end
                else if(pos_for_new_data == 2'b01) begin
                    lru[index][5:3] <= 3'b000;
                    cache_dirty_bit[index][1] <= 1'b0;
                    cache_size_data[128+index] <= data;
                    cache_tag[128+index] <= tag;
                    cache_valid_bit[128+index] <= 1'b1;
                end
                else if(pos_for_new_data == 2'b00) begin
                    lru[index][2:0] <= 3'b000;
                    cache_dirty_bit[index][0] <= 1'b0;
                    cache_size_data[index] <= data;
                    cache_tag[index] <= tag;
                    cache_valid_bit[index] <= 1'b1;
                end
                
            end

        end
    end

    always @(posedge clk,negedge rst) begin
        if(c4 == 1'b1) begin
            ask_for_data <= 1'b1;
        end
        else begin
            ask_for_data <= 1'b0;
        end
    end


    
    //LRU
    always @(posedge clk,negedge rst) begin
        if(c3 == 1'b1) begin
            //When you get a hit and reset the LRU data to 0 and increment the over LRU data
            if(temp_and_values == 4'b1000) begin //set1
                lru[index][11:9] <= 3'b0;
                if(lru[index][8:6] < 3'b011) begin
                    lru[index][8:6] <= lru[index][8:6] + 3'b001;
                end
                if(lru[index][5:3] < 3'b011) begin
                    lru[index][5:3] <= lru[index][5:3] + 3'b001;
                end
                if(lru[index][2:0] < 3'b011) begin
                    lru[index][2:0] <= lru[index][2:0] + 3'b001;
                end

            end 
            else if(temp_and_values == 4'b0100) begin //set2
                lru[index][8:6] <= 3'b0;
                if(lru[index][11:9] < 3'b011) begin
                    lru[index][11:9] <= lru[index][11:9] + 3'b001;
                end
                if(lru[index][5:3] < 3'b011) begin
                    lru[index][5:3] <= lru[index][5:3] + 3'b001;
                end
                if(lru[index][2:0] < 3'b011) begin
                    lru[index][2:0] <= lru[index][2:0] + 3'b001;
                end
            end
            else if(temp_and_values == 4'b0010) begin //set3
                lru[index][5:3] <= 3'b0;
                if(lru[index][8:6] < 3'b011) begin
                    lru[index][8:6] <= lru[index][8:6] + 3'b001;
                end
                if(lru[index][11:9] < 3'b011) begin
                    lru[index][11:9] <= lru[index][11:9] + 3'b001;
                end
                if(lru[index][2:0] < 3'b011) begin
                    lru[index][2:0] <= lru[index][2:0] + 3'b001;
                end
            end
            else if(temp_and_values == 4'b0001) begin //set4
                lru[index][2:0] <= 3'b0;
                if(lru[index][8:6] < 3'b011) begin
                    lru[index][8:6] <= lru[index][8:6] + 3'b001;
                end
                if(lru[index][5:3] < 3'b011) begin
                    lru[index][5:3] <= lru[index][5:3] + 3'b001;
                end
                if(lru[index][11:9] < 3'b011) begin
                    lru[index][11:9] <= lru[index][11:9] + 3'b001;
                end
            end
        end

        if(c5 == 1'b1) begin
            
            //When you get a miss and need to give a position for the next data if there
            //is space in cache
            if(lru[index][11:9] == 3'b100) begin
                pos_for_new_data <= 2'b11;
                space_in_lru <= 1'b0;
                
            end
            else if(lru[index][8:6] == 3'b100) begin
                pos_for_new_data <= 2'b10;
                space_in_lru <= 1'b0;
                
            end
            else if(lru[index][5:3] == 3'b100) begin
                pos_for_new_data <= 2'b01;
                space_in_lru <= 1'b0;
                
            end
            else if(lru[index][2:0] == 3'b100) begin
                pos_for_new_data <= 2'b00;
                space_in_lru <= 1'b0;
                
            end
            else begin
                space_in_lru <= 1'b1;
                
            end
            
        end

        if(c7 == 1'b1) begin
            //makes space in cache when everything is full by giving the position 
            //of the last reacent used set
            if(lru[index][11:9] == 3'b011) begin
                pos_for_new_data <= 2'b11;
            end
            else if(lru[index][8:6] == 3'b011) begin
                pos_for_new_data <= 2'b10;
            end
            else if(lru[index][5:3] == 3'b011) begin
                pos_for_new_data <= 2'b01;
            end
            else if(lru[index][2:0] == 3'b011) begin
                pos_for_new_data <= 2'b00;
            end
            
        end 
        
    end


endmodule

