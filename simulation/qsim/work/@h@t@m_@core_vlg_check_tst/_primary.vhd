library verilog;
use verilog.vl_types.all;
entity HTM_Core_vlg_check_tst is
    port(
        TransactionStatus: in     vl_logic_vector(2 downto 0);
        sampler_rx      : in     vl_logic
    );
end HTM_Core_vlg_check_tst;
