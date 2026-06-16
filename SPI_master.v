`timescale 1ns / 1ps


// SPI Master
// Supported Mode:
// CPOL = 0
// CPHA = 0
// Full-duplex, 8-bit transfer

module SPI_master(
    clk,
    spi_clk,
    tx_data,
    rx_data,
    tx_start,
    reset,
    MISO,
    MOSI,
    CS
    );
    
    input clk, reset, MISO,tx_start;
    input [7:0] tx_data;
    output reg [7:0] rx_data;
    output spi_clk, MOSI;
    output reg CS;
    
    localparam IDLE = 2'b00;
    localparam SELECT = 2'b01;
    localparam TRANSFER = 2'b10;
    localparam DESELECT = 2'b11;
    
    reg [1:0] state, next_state;
    reg [7:0] tx_shift_reg;
    reg [7:0] rx_shift_reg;
    reg [3:0] bit_count;
    
    parameter SPI_DIV = 4;

    reg [15:0] div_count;
    reg spi_clk_reg;
    reg spi_rise_pulse;
    reg spi_fall_pulse;
    
    assign spi_clk = spi_clk_reg;
    assign MOSI = tx_shift_reg[7];
    
    always@(posedge clk or posedge reset)
    begin
        if (reset)
            state <= IDLE;
        else
            state <= next_state; 
        end
        
    // CLOCK DIVIDER
    always @(posedge clk or posedge reset)
    begin
        spi_rise_pulse <= 0;
        spi_fall_pulse <= 0;
        
        if(reset)
        begin
            div_count <= 0;
            spi_clk_reg <= 0;
        end
    
        else if(state == TRANSFER)
        begin
            
            if(div_count == SPI_DIV-1)
            begin
                div_count <= 0;
                if (spi_clk_reg)
                begin
                    spi_fall_pulse <= 1;
                    spi_clk_reg <= 0;
                end
                else
                begin
                    spi_rise_pulse <= 1;
                    spi_clk_reg <= 1;
                end
            end
            else
                div_count <= div_count + 1;
        end
    
        else
        begin
            div_count <= 0;
            spi_clk_reg <= 0;
        end
    end
    
    // NEXT-STATE LOGIC
    
    always@(*)
    begin
    
        next_state = state;
        
        case(state)
            
            IDLE:
                if(tx_start)
                    next_state = SELECT;
                else
                    next_state = IDLE;
                
            SELECT:
                next_state = TRANSFER;
            
            TRANSFER:
            begin
                if(bit_count == 8)
                    next_state = DESELECT;
                else
                    next_state = TRANSFER;
            end
            
            DESELECT:
                next_state = IDLE;
            
            default: next_state = IDLE;
        endcase
    end
    
    //OUTPUT LOGIC
    
    always@(*)
    begin
        
        CS = 1;
        
        case (state)
            
            IDLE: CS = 1;
            SELECT: CS = 0;
            TRANSFER : CS = 0;
            DESELECT : CS = 1;
            
            default : CS = 1;
         endcase
    end
    
    // DATA PATH LOGIC
    always@(posedge clk or posedge reset)
    begin
        if(reset)
            begin
                tx_shift_reg <= 0;
                rx_shift_reg <= 0;
                rx_data <= 0;
                bit_count <= 0;
            end
        else if(state == IDLE && tx_start == 1)
            begin
                tx_shift_reg <= tx_data;
                rx_shift_reg <= 0;
                bit_count <= 0;
            end
        else
            begin
            
                case(state)
                
                    TRANSFER:
                        begin
                        
                        if(spi_fall_pulse)
                        begin
                        tx_shift_reg <= tx_shift_reg << 1;
                        bit_count <= bit_count + 1;
                        end
                        
                        if (spi_rise_pulse)
                        begin
                        rx_shift_reg <= {rx_shift_reg[6:0], MISO};
                        end
                        end
                    DESELECT:
                    begin
                        rx_data <= rx_shift_reg;
                        bit_count <= 0; 
                    end
                endcase  
                

            end
    end
endmodule
