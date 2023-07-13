library verilog;
use verilog.vl_types.all;
entity HTM_Core is
    port(
        Action          : in     vl_logic_vector(1 downto 0);
        MemAddress      : in     vl_logic_vector(7 downto 0);
        Data            : in     vl_logic_vector(7 downto 0);
        ProcID          : in     vl_logic_vector(1 downto 0);
        TransactionID   : in     vl_logic_vector(1 downto 0);
        TransactionStatus: out    vl_logic_vector(2 downto 0);
        Reset           : in     vl_logic;
        Clock           : in     vl_logic
    );
end HTM_Core;
