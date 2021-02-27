module simple_fifo #(
  parameter WIDTH = 32,
  parameter DEPTH = 1
) (
  input   clk,
  input   reset_n,
  input   push,
  input   pop,
  output  empty,
  output  full,
  input   [WIDTH-1:0] data_i,
  output  [WIDTH-1:0] data_o,
  output  [PTR_W-1:0] rd_ptr_,
  output  [PTR_W-1:0] wr_ptr_
);

localparam PTR_W = DEPTH > 1? $clog2(DEPTH):1;

logic [WIDTH-1:0] mem [DEPTH-1:0];

logic [PTR_W-1:0] next_rd_ptr;
logic [PTR_W-1:0] next_wr_ptr;
logic [PTR_W-1:0] wr_ptr ;
logic [PTR_W-1:0] rd_ptr ;

logic             next_rd_polarity;
logic             next_wr_polarity;
logic             rd_polarity;
logic             wr_polarity;

always_comb begin : p_next_ptr_ctrl
  next_wr_ptr      =           push ?  wr_ptr + 1 : wr_ptr; 
  next_rd_ptr      =           pop  ?  rd_ptr + 1 : rd_ptr; 
  next_rd_polarity = &rd_ptr & pop  ? ~rd_polarity : rd_polarity;   
  next_wr_polarity = &wr_ptr & push ? ~wr_polarity : wr_polarity;
end

assign empty = ~(rd_polarity ^ wr_polarity) & (wr_ptr == rd_ptr);
assign full  =  (rd_polarity ^ wr_polarity) & (wr_ptr == rd_ptr);

always_ff @( posedge clk or negedge reset_n ) begin : p_ptr_ctrl
  if (!reset_n) begin
    wr_ptr      <= '0;
    rd_ptr      <= '0;
    wr_polarity <= '0;
    rd_polarity <= '0;
  end else begin
    wr_ptr      <= next_wr_ptr;
    rd_ptr      <= next_rd_ptr;
    wr_polarity <= next_wr_polarity;
    rd_polarity <= next_rd_polarity;
  end
end

always_ff @( posedge clk ) begin : p_mem_write
  if (push) begin
    mem[wr_ptr] <= data_i;
  end
end 

assign data_o = mem[rd_ptr-1];

// Debug 
assign rd_ptr_ = rd_ptr;
assign wr_ptr_ = wr_ptr;

endmodule