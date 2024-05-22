module struct_tb;

reg clk;
reg rst;
reg bgn;
reg write;
reg read;
reg [511:0] data;
reg [31:0] address;
wire [511:0] outbus;
wire t0,t1,t2,t3,t4,t5,t6,t7;
wire hit_bar;
wire [3:0] and_val;


struct uut (
    .clk(clk),
    .rst(rst),
    .bgn(bgn),
    .write(write),
    .read(read),
    .data(data),
    .address(address),
    .outbus(outbus),
    .t0(t0),.t1(t1),.t2(t2),.t3(t3),.t4(t4),.t5(t5),.t6(t6),.t7(t7),.hit_bar(hit_bar),.and_val(and_val)
);


initial begin
    clk = 0;
    repeat (400) begin
        #10 clk = ~clk;
    end
    $stop; 
end 

initial begin
    
    rst = 1;
    bgn = 0;
    write = 0;
    read = 0;

    // Reset
    #20;
    rst = 0;

    //CASE 1

    // data = 512'hA1B2C3D4E5F60789_9876543210FEDCBA_BBCCDDEEFF001122_33445566778899AA_1122334455667788_99AABBCCDDEEFF00_0011223344556677_8899AABBCCDDEEFF;
    // address = 32'h12345678;

    // //WRITE
    // #40;
    // bgn = 1;
    // #40;
    // bgn = 0;
    // #40;
    // write = 1;
    // #20;
    // write = 0;
    // #200;

    // //READ
    // #40;
    // bgn = 1;
    // #40;
    // read = 1;
    // #40;
    // bgn = 0;
    // #20;
    // read = 0;
    // #200;


    // address = 32'hEFFFEF0A;
    // data = 512'hCAFEBABEDEADBEEF_1234567890ABCDEF_FEDCBA9876543210_0A1B2C3D4E5F6789_AABBCCDDEEFF0011_99AABBCCDDEEFF00_1122334455667788_8899AABBCCDDEEFF;

    // //WRITE
    // #40;
    // bgn = 1;
    // #40;
    // bgn = 0;
    // #40;
    // write = 1;
    // #20;
    // write = 0;
    // #200;

    // //READ
    // #40;
    // bgn = 1;
    // #40;
    // bgn = 0;
    // #40;
    // read = 1;
    // #20;
    // read = 0;
    // #200;

    // address = 32'h12345678;

    // //READ
    // #40;
    // bgn = 1;
    // #40;
    // read = 1;
    // #40;
    // bgn = 0;
    // #20;
    // read = 0;
    // #200;

    // address = 32'hEFAFEF0A;
    // data = 512'hf1B2C3D4E5F60789_9876543210FEDCBA_BBCCDDEEFF001122_33445566778899AA_1122334455667788_99AABBCCDDEEFF00_0011223344556677_8899AABBCCDDEEFF;

    // //WRITE
    // #40;
    // bgn = 1;
    // #40;
    // bgn = 0;
    // #40;
    // write = 1;
    // #20;
    // write = 0;
    // #200;

    // //READ
    // #40;
    // bgn = 1;
    // #40;
    // read = 1;
    // #40;
    // bgn = 0;
    // #20;
    // read = 0;
    // #200;


    // address = 32'hEFFFEF0A;
    

    // //READ
    // #40;
    // bgn = 1;
    // #40;
    // read = 1;
    // #40;
    // bgn = 0;
    // #20;
    // read = 0;
    // #200;

    // address = 32'h12345678;

    // //READ
    // #40;
    // bgn = 1;
    // #40;
    // read = 1;
    // #40;
    // bgn = 0;
    // #20;
    // read = 0;
    // #200;

    //-----------------------------------------------------------------------------------------------------------------------------------------------

    //CASE 2

    address = 32'hEFAFEF0A;
    data = 512'hf1B2C3D4E5F60789_9876543210FEDCBA_BBCCDDEEFF001122_33445566778899AA_1122334455667788_99AABBCCDDEEFF00_0011223344556677_8899AABBCCDDEEFF;

    
    //WRITE
    #40;
    bgn = 1;
    #40;
    bgn = 0;
    #40;
    write = 1;
    #20;
    write = 0;
    #200;

    address = 32'hCFAFEF0A;
    data = 512'hA1B2C3D4E5F60789_9876543210FEDCBA_BBCCDDEEFF001122_33445566778899AA_1122334455667788_99AABBCCDDEEFF00_0011223344556677_8899AABBCCDDEEFF;

    
    //WRITE
    #40;
    bgn = 1;
    #40;
    bgn = 0;
    #40;
    write = 1;
    #20;
    write = 0;
    #200;

    address = 32'hAFAFEF0A;
    data = 512'h91B2C3D4E5F60789_9876543210FEDCBA_BBCCDDEEFF001122_33445566778899AA_1122334455667788_99AABBCCDDEEFF00_0011223344556677_8899AABBCCDDEEFF;

    
    //WRITE
    #40;
    bgn = 1;
    #40;
    bgn = 0;
    #40;
    write = 1;
    #20;
    write = 0;
    #200;

    address = 32'hBFAFEF0A;
    data = 512'h81B2C3D4E5F60789_9876543210FEDCBA_BBCCDDEEFF001122_33445566778899AA_1122334455667788_99AABBCCDDEEFF00_0011223344556677_8899AABBCCDDEEFF;

    
    //WRITE
    #40;
    bgn = 1;
    #40;
    bgn = 0;
    #40;
    write = 1;
    #20;
    write = 0;
    #200;


    address = 32'hEFAFEF0A;

    //READ
    #40;
    bgn = 1;
    #40;
    read = 1;
    #40;
    bgn = 0;
    #20;
    read = 0;
    #200;


    address = 32'hAFAFEF0A;

    //READ
    #40;
    bgn = 1;
    #40;
    read = 1;
    #40;
    bgn = 0;
    #20;
    read = 0;
    #200;


    address = 32'hBFAFEF0A;

    //READ
    #40;
    bgn = 1;
    #40;
    read = 1;
    #40;
    bgn = 0;
    #20;
    read = 0;
    #200;

    address = 32'hCFAFEF0A;

    //READ
    #40;
    bgn = 1;
    #40;
    read = 1;
    #40;
    bgn = 0;
    #20;
    read = 0;
    #200;



end


endmodule
