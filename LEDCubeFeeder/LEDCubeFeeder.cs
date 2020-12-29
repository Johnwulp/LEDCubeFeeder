using System;
using System.Data;
using System.Linq;
using System.ServiceProcess;
using System.Text;
using System.Timers;
using OpenHardwareMonitor.Hardware;
using System.Net.Sockets;
using System.Diagnostics;

namespace LEDCubeFeeder
{
    public partial class LEDCubeFeeder : ServiceBase
    {
        private static readonly NLog.Logger Logger = NLog.LogManager.GetCurrentClassLogger();
        Computer thisComputer;
        public LEDCubeFeeder()
        {
            InitializeComponent();
            thisComputer = new Computer() { CPUEnabled = true };
            thisComputer.Open();
        }

        protected override void OnStart(string[] args)
        {
            Logger.Info("Starting...");
            Timer timer = new Timer
            {
                Interval = Properties.Settings.Default.updateinterval
            };
            timer.Elapsed += new ElapsedEventHandler(this.OnTimer);
            timer.Start();
        }

        private void OnTimer(object sender, ElapsedEventArgs e)
        {
            try
            {
                Logger.Debug("Timer tick!");

                foreach (var hardwareItem in thisComputer.Hardware)
                {
                    if (hardwareItem.HardwareType == HardwareType.CPU)
                    {
                        hardwareItem.Update();
                        foreach (IHardware subHardware in hardwareItem.SubHardware)
                            subHardware.Update();

                        foreach(ISensor sensor in hardwareItem.Sensors)
                        {
                            Logger.Debug($"Found sensor name: '{sensor.Name}' from type '{sensor.SensorType}' with value: {sensor.Value}");
                        }

                        var _temp = hardwareItem.Sensors.Where(s => (s.SensorType == SensorType.Temperature) && s.Name.Equals("CPU Package")).FirstOrDefault();
                        string temp = String.Format("{0:0}", _temp.Value);
                        Logger.Debug($"{_temp.Name} Temp = {temp}");

                        var _cpu = hardwareItem.Sensors.Where(s => (s.SensorType == SensorType.Load) & !s.Name.Equals("CPU Total")).ToList();
                        foreach (ISensor cpu in _cpu)
                            Logger.Debug($"name: {cpu.Name} value: {String.Format("{0:0}", cpu.Value)}");

                        string loads = string.Join(",", _cpu.Select(i => String.Format("{0:0}", i.Value)).ToArray());
                        Logger.Debug($"Loads: {loads}");

                        string sendUDPData = $"{temp},{loads}";

                        //sending UDP Data
                        Logger.Debug($"Sending: '{sendUDPData}' to server: '{Properties.Settings.Default.ledcubeserver}' on port: '{Properties.Settings.Default.ledcubeport}'");
                        UdpClient udpClient = new UdpClient(Properties.Settings.Default.ledcubeserver, Properties.Settings.Default.ledcubeport);
                        Byte[] sendBytes = Encoding.UTF8.GetBytes(sendUDPData);
                        try
                        {
                            udpClient.Send(sendBytes, sendBytes.Length);
                        }
                        catch (Exception ex)
                        {
                            Logger.Error(ex, "Got exception during upd sending");  
                        }
                    }
                    else
                    {
                        Logger.Error("No HardwareType.CPU found!");
                    }
                }
            }
            catch (Exception ex)
            {
                var st = new StackTrace(ex, true);
                var frame = st.GetFrame(0);
                var line = frame.GetFileLineNumber();
                Logger.Error(ex, $"Got exception from thisComputer.Hardware on line {line}");
            }
        }
        protected override void OnStop()
        {
            Logger.Info("Ending...");
        }
    }
}
