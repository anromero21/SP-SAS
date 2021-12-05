-------------------------------------------------------------------- 
-- Maquina de estados secuencial para una envasadora de pastillas --
-- 				            			  -- 
--------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

entity sp is
  GENERIC(
    clk_freq   :  integer    := 50);    --system clock frequency in MHz
  port(
    clk, reset : in   STD_LOGIC;                      --reloj
    sensor  : in std_logic_vector(1 downto 0);
    dispos    : out std_logic_vector(2 downto 0 );        -- Dispositivos que llevan acabo cada accion
    state     : out std_logic_vector (3 downto 0));  -- Leds que indican el estado 
end sp;

architecture rtl OF sp is
  type estados is(Llenado, sella, rota);
  signal  pasos  : estados;
begin
  process(clk)
    variable rota_cuenta : integer := 0;  	     -- 
    variable clk_count : integer := 0;  	     -- Contador de ciclos de reloj transcurrido
  begin
    if(clk'EVENT and clk = '1') then
	if (reset = '0' ) then	

	      case pasos is
	         
	        when Llenado =>				     -- Llena el pasitllero
			-- Wait a little 2s so the pastillero is correctly set or removed 
			--  Turn on busy led while you wait
			-- Turn it off 
			-- Turn on llenado led 
			-- activate disp_1
			-- Fill the container (stay there) untill a sensor (switch) gives the signal
			-- Turn off llenado led
			-- deactivate disp_1
			-- change state to sella
			if (clk_count < (2000000 * clk_freq)) then 
			clk_count := clk_count + 1;
			state(3) <='1';
			pasos<=llenado;
			else
				state(3) <='0';
				state(0) <='1';
				dispos(0)<='1';
				if (sensor(0) ='1') then
				clk_count:=0;
				state(0)<='0';
				dispos(0)<='0';
				state(3) <='0';
				pasos<=sella;
				else
				pasos<= llenado; 
				end if;
			end if; 
		when sella =>                                -- Sella el pastillero
			-- Turn on sellado led
			-- activate disp_2
			-- wait here until a sensor gives the signal 
			-- turn off disp_2
			-- turn off sellado led
			-- Change satete to rota 
			if(sensor(1) = '1') then 
			state(1)<='0';
			dispos(1) <='0';
			pasos<= rota;
			else
			state(1) <='1';
			dispos(1)<='1';
			pasos<= sella;
			end if;
		when rota =>				     --  Rota y llena el siguiente envase 
			-- Turn on rota led 
			-- activate disp_3
			-- wait for time and turn on busy led
			-- done turn off busy led 
			-- deactivate disp_3
			-- turn off led rota
			-- change state to llenadoD
			state(2)<='1';
			dispos(2)<='1';
			if (clk_count < (5000000 * clk_freq)) then 
			clk_count := clk_count + 1;
			--state(3)<='1';
			pasos<=rota;
			else 
			--state(3)<='0';
			clk_count:=0;
			state(2)<='0';
			dispos(2)<='0';
			pasos<=Llenado;
			end if;
	      end case;
	     else 
		state<="0000";
		dispos<= "000";
		clk_count:=0;
		pasos<=Llenado;
	     end if;
	end  if;
   end process;
end rtl;



