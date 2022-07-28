subplot(4,1,1)
plot(time_p, torque_p)
title('torque')

subplot(4,1,2)
plot(time_p, fl(:, 22))
title('fascicle length')

subplot(4,1,3)
plot(time_p, penn(:, 22))
title('pennation angle')

subplot(4,1,4)
plot(time_p, thick(:, 2))
title('thickness')

