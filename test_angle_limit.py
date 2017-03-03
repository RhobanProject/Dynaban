import pypot.dynamixel
import time

ports = pypot.dynamixel.get_available_ports()
print ports
dxl_io = pypot.dynamixel.DxlIO(ports[0], baudrate=1000000)

for i in range(10) :
    dxl_io.set_angle_limit({1:[150, -150]})
    time.sleep(0.1)
    dxl_io.enable_torque([1])
    time.sleep(0.1)

while(True) :
    print("ok")
#    print(dxl_io.get_present_position([1]))
    time.sleep(0.1)
    dxl_io.set_goal_position({1:145})
    time.sleep(1)
    dxl_io.set_goal_position({1:-145})
    time.sleep(1)
