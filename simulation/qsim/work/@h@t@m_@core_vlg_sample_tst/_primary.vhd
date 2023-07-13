library verilog;
use verilog.vl_types.all;
entity HTM_Core_vlg_sample_tst is
    port(
        Action          : in     vl_logic_vector(1 downto 0);
        Clock           : in     vl_logic;
        Data            : in     vl_logic_vector(7 downto 0);
        MemAddress      : in     vl_logic_vector(7 downto 0);
        ProcID          : in     vl_logic_vector(1 downto 0);
        Reset           : in     vl_logic;
        TransactionID   : in     vl_logic_vector(1 downto 0);
        sampler_tx      : out    vl_logic
    );
end HTM_Core_vlg_sample_tst;
