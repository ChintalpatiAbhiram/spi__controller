`timescale 1ns / 1ps

module SPI_tb;

    reg clk;
    reg [7:0] master_tx_data;
    reg [7:0] slave_tx_data;
    reg tx_start;
    reg reset;
    
    
    wire spi_miso;
    wire spi_sclk;
    wire spi_mosi;
    wire spi_cs;
    wire [7:0] master_rx_data;
    wire [7:0] slave_rx_data;
    
SPI_master master(
    .clk(clk),
    .spi_clk(spi_sclk),
    .tx_data(master_tx_data),
    .tx_start(tx_start),
    .rx_data(master_rx_data),
    .reset(reset),
    .MISO(spi_miso),
    .MOSI(spi_mosi),
    .CS(spi_cs)
);

SPI_slave slave(
    .clk(clk),
    .spi_clk(spi_sclk),
    .tx_data(slave_tx_data),
    .rx_data(slave_rx_data),
    .reset(reset),
    .MISO(spi_miso),
    .MOSI(spi_mosi),
    .CS(spi_cs)
);

always #5 clk = ~clk;

initial 
begin

    $monitor(
    "TIME=%0t | CS=%b | MOSI=%b | MISO=%b\n\
MASTER : STATE=%0d | TX_SHIFT=%b | RX_SHIFT=%b | RX_DATA=%b | BIT_COUNT=%0d\n\
SLAVE  : STATE=%0d | TX_SHIFT=%b | RX_SHIFT=%b | RX_DATA=%b\n",
        $time,
        spi_cs,
        spi_mosi,
        spi_miso,

        master.state,
        master.tx_shift_reg,
        master.rx_shift_reg,
        master_rx_data,
        master.bit_count,

        slave.state,
        slave.tx_shift_reg,
        slave.rx_shift_reg,
        slave_rx_data
    );
    
    clk = 0;
    reset = 1;
    tx_start = 0;
    master_tx_data = 8'b11010010;
    slave_tx_data = 8'b01101101;
    
    #20;
    reset = 0;
    
    #20;
    tx_start = 1;
    
    #10;
    tx_start = 0;
    
    #3000;
    
    $finish;
end
endmodule
