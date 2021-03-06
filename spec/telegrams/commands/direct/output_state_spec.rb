require './spec/helper'
require './lib/telegrams/commands/direct/output_state'

describe OutputState do
  # attr_reader :port, :power, :mode, :regulation_mode, :turn_ratio, :run_state, :tacho_limit

  # this next group can only be read from a GetOutputState call:
  #   tacho_count # internal count; number of counts since last reset of the motor counter
  #   block_tacho_count # current position relative to last programmed movement
  #   rotation_count # current position relative to last reset of the rotation sensor for this motor
  describe "when constructing the object" do
    it "must accept hash contructor arguments with defaults of 0" do
      state = OutputState.new({ :port => :a })
      state.port.must_equal :a
      state.mode_flags.must_equal 0
    end
  end

  describe "when using the builder structure" do
    before do
      @state = OutputState.new
    end

    it "must accept a 'for_port(port_symbol) message that sets the value and returns the object itself" do
      @state.for_port(:a).must_equal @state
      @state.port.must_equal :a
    end

    it "must accept a 'with_power(power)' message that sets the value and returns the object itself" do
      @state.with_power(100).must_equal @state
      @state.power.must_equal 100
    end

    it "must accept a 'with_mode_flags(mode_flags)' that sets the value and returns the object itself" do
      @state.with_mode_flags(OutputModeFlags.MOTORON | OutputModeFlags.REGULATED).must_equal @state
      @state.mode_flags.must_equal OutputModeFlags.MOTORON | OutputModeFlags.REGULATED
    end

    it "must accept a 'with_regulation_mode(regulation_mode)' that sets the value and returns the object itself" do
      @state.with_regulation_mode(:motor_speed).must_equal @state
      @state.regulation_mode.must_equal :motor_speed
    end

    it "must accept a 'with_turn_ratio(turn_ratio)' message that sets the value and returns the object itself" do
      @state.with_turn_ratio(100).must_equal @state
      @state.turn_ratio.must_equal 100
    end

    it "must accept a 'with_run_state(run_state)' that sets the value and returns the object itself" do
      @state.with_run_state(:ramp_up).must_equal @state
      @state.run_state.must_equal :ramp_up
    end

    it "must accept a 'with_tacho_limit(tacho_limit)' that sets the value and returns the object itself" do
      @state.with_tacho_limit(325).must_equal @state
      @state.tacho_limit.must_equal 325
    end
  end

  describe "when using the setter methods" do
    before do
      @state = OutputState.new
    end

    it "must validate that the port is :a, :b, :c, or :all" do
      @state.port = :a
      @state.port = :b
      @state.port = :c
      @state.port = :all
      -> { @state.port = :d }.must_raise ArgumentError
    end

    it "must set the port when it is set" do
      @state.port = :b
      @state.port.must_equal :b
    end

    it "must validate that the power is between -100 and 100" do
      [-100, 0, 100].each do |power|
        @state.power = power
        @state.power.must_equal power
      end
      -> { @state.power = -101 }.must_raise ArgumentError
      -> { @state.power = 101 }.must_raise ArgumentError
    end

    it "must vaidate that the mode_flags is a valid combination of 0 to all flags (0-7 as an integer)" do
      (0..7).each do |mode|
        @state.mode_flags = mode
        @state.mode_flags.must_equal mode
      end

      -> { @state.mode_flags = 8 }.must_raise ArgumentError
    end

    it "must validate that the regulation_mode is one of the valid enumerations" do
      [:idle, :motor_speed, :motor_sync].each do |regulation_mode|
        @state.regulation_mode = regulation_mode
        @state.regulation_mode.must_equal regulation_mode
      end

      -> { @state.regulation_mode = :garbage }.must_raise ArgumentError
      -> { @state.regulation_mode = 1 }.must_raise ArgumentError
    end

    it "must validate that the turn_ratio is between -100 and 100" do
      [-100, 0, 100].each do |turn_ratio|
        @state.turn_ratio = turn_ratio
        @state.turn_ratio.must_equal turn_ratio
      end
      -> { @state.turn_ratio = -101 }.must_raise ArgumentError
      -> { @state.turn_ratio = 101 }.must_raise ArgumentError
    end

    it "must validate that the run_state is one of the valid enumerations" do
      [:idle, :running, :ramp_up, :ramp_down].each do |run_state|
        @state.run_state = run_state
        @state.run_state.must_equal run_state
      end

      -> { @state.run_state = :garbage }.must_raise ArgumentError
      -> { @state.run_state = 1 }.must_raise ArgumentError
    end

    it "must have a constant representing 'run forever' or 'unlimited'" do
      OutputState.RUN_FOREVER.must_equal 0
    end

    it "must set the tacho_limit" do
      @state.tacho_limit = 39123  # it's an unsigned long value, 4 bytes
      @state.tacho_limit.must_equal 39123
    end
  end
end

describe OutputModeFlags do
  it "must have MOTORON set to 0x01" do
    OutputModeFlags.MOTORON.must_equal 0x01
  end

  it "must have BRAKE set to 0x02" do
    OutputModeFlags.BRAKE.must_equal 0x02
  end

  it "must have REGULATED set to 0x04" do
    OutputModeFlags.REGULATED.must_equal 0x04
  end

  it "must allow MOTORON and BRAKE to be combined into 0x03" do
    (OutputModeFlags.MOTORON | OutputModeFlags.BRAKE).must_equal 0x03
  end

  it "must allow MOTORON and REGULATED to be combined into 0x05" do
    (OutputModeFlags.MOTORON | OutputModeFlags.REGULATED).must_equal 0x05
  end

  it "must allow BRAKE and REGULATED to be combined into 0x06" do
    (OutputModeFlags.BRAKE | OutputModeFlags.REGULATED).must_equal 0x06
  end

  it "must allow all three to be combined into 0x07" do
    (OutputModeFlags.MOTORON | OutputModeFlags.BRAKE | OutputModeFlags.REGULATED).must_equal 0x07
  end
end


describe RegulationMode do
  it "must have IDLE defined as 0x00" do
    RegulationMode.IDLE.must_equal 0x00
  end

  it "must have MOTOR_SPEED defined as 0x01" do
    RegulationMode.MOTOR_SPEED.must_equal 0x01
  end

  it "must have MOTOR_SYNC defined as 0x02" do
    RegulationMode.MOTOR_SYNC.must_equal 0x02
  end
end


describe RunState do
  it "must have IDLE defined as 0x00" do
    RunState.IDLE.must_equal 0x00
  end

  it "must have RAMPUP defined as 0x10" do
    RunState.RAMPUP.must_equal 0x10
  end

  it "must have RUNNING defined as 0x20" do
    RunState.RUNNING.must_equal 0x20
  end

  it "must have RAMPDOWN defined as 0x40" do
    RunState.RAMPDOWN.must_equal 0x40
  end
end
