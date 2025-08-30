component or2_gate
port(w1: out std_logic; A,B: in std_logic);
end component;

component inv_gate
port (B: out std_logic; A in std_logic);
end component;

signal w1: std_logic;

begin 
    G1: and2_gate port map (w1, A, B);
    G2: inv_gate  port map (E,C);
    G3: or2_gate port map (D, w1, E);

end architecture Structure;