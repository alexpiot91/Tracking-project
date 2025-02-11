function result = fusionMadgwickWiner(result, acc, gyr, mag, beta, zeta, deltat)
    q1 = result(1); q2 = result(2); q3 = result(3); q4 = result(4); g_bx = result(5); g_by = result(6); g_bz = result(7);   % short name local variable for readability
    
    ax = acc(1);
    ay = acc(2);
    az = acc(3);
    gx = gyr(1);
    gy = gyr(2);
    gz = gyr(3);
    mx = mag(2);
    my = mag(1);
    mz = -mag(3);

    % Auxiliary variables to avoid repeated arithmetic
    two_q1 = 2 * q1;
    two_q2 = 2 * q2;
    two_q3 = 2 * q3;
    two_q4 = 2 * q4;
    two_q1q3 = 2 * q1 * q3;
    two_q3q4 = 2 * q3 * q4;
    q1q1 = q1 * q1;
    q1q2 = q1 * q2;
    q1q3 = q1 * q3;
    q1q4 = q1 * q4;
    q2q2 = q2 * q2;
    q2q3 = q2 * q3;
    q2q4 = q2 * q4;
    q3q3 = q3 * q3;
    q3q4 = q3 * q4;
    q4q4 = q4 * q4;

    % Normalise accelerometer measurement
    norm = sqrt(ax * ax + ay * ay + az * az);
    if (norm == 0)
        error('Norm error calculation');
    end
    ax = ax / norm;
    ay = ay / norm;
    az = az / norm;

    % Normalise magnetometer measurement
    norm = sqrt(mx * mx + my * my + mz * mz);
    if (norm == 0)
        error('Norm error calculation');
    end
    mx = mx / norm;
    my = my / norm;
    mz = mz / norm;

    % Reference direction of Earth's magnetic field
    two_q1mx = 2 * q1 * mx;
    two_q1my = 2 * q1 * my;
    two_q1mz = 2 * q1 * mz;
    two_q2mx = 2 * q2 * mx;
    hx = mx * q1q1 - two_q1my * q4 + two_q1mz * q3 + mx * q2q2 + two_q2 * my * q3 + two_q2 * mz * q4 - mx * q3q3 - mx * q4q4;
    hy = two_q1mx * q4 + my * q1q1 - two_q1mz * q2 + two_q2mx * q3 - my * q2q2 + my * q3q3 + two_q3 * mz * q4 - my * q4q4;
    two_bx = sqrt(hx * hx + hy * hy);
    two_bz = -two_q1mx * q3 + two_q1my * q2 + mz * q1q1 + two_q2mx * q4 - mz * q2q2 + two_q3 * my * q4 - mz * q3q3 + mz * q4q4;
    four_bx = 2 * two_bx;
    four_bz = 2 * two_bz;

    % Gradient decent algorithm corrective step
    s1 = -two_q3 * (2 * q2q4 - two_q1q3 - ax) + two_q2 * (2 * q1q2 + two_q3q4 - ay) - two_bz * q3 * (two_bx * (0.5 - q3q3 - q4q4) + two_bz * (q2q4 - q1q3) - mx) + (-two_bx * q4 + two_bz * q2) * (two_bx * (q2q3 - q1q4) + two_bz * (q1q2 + q3q4) - my) + two_bx * q3 * (two_bx * (q1q3 + q2q4) + two_bz * (0.5 - q2q2 - q3q3) - mz);
    s2 = two_q4 * (2 * q2q4 - two_q1q3 - ax) + two_q1 * (2 * q1q2 + two_q3q4 - ay) - 4 * q2 * (1 - 2 * q2q2 - 2 * q3q3 - az) + two_bz * q4 * (two_bx * (0.5 - q3q3 - q4q4) + two_bz * (q2q4 - q1q3) - mx) + (two_bx * q3 + two_bz * q1) * (two_bx * (q2q3 - q1q4) + two_bz * (q1q2 + q3q4) - my) + (two_bx * q4 - four_bz * q2) * (two_bx * (q1q3 + q2q4) + two_bz * (0.5 - q2q2 - q3q3) - mz);
    s3 = -two_q1 * (2 * q2q4 - two_q1q3 - ax) + two_q4 * (2 * q1q2 + two_q3q4 - ay) - 4 * q3 * (1 - 2 * q2q2 - 2 * q3q3 - az) + (-four_bx * q3 - two_bz * q1) * (two_bx * (0.5 - q3q3 - q4q4) + two_bz * (q2q4 - q1q3) - mx) + (two_bx * q2 + two_bz * q4) * (two_bx * (q2q3 - q1q4) + two_bz * (q1q2 + q3q4) - my) + (two_bx * q1 - four_bz * q3) * (two_bx * (q1q3 + q2q4) + two_bz * (0.5 - q2q2 - q3q3) - mz);
    s4 = two_q2 * (2 * q2q4 - two_q1q3 - ax) + two_q3 * (2 * q1q2 + two_q3q4 - ay) + (-four_bx * q4 + two_bz * q2) * (two_bx * (0.5 - q3q3 - q4q4) + two_bz * (q2q4 - q1q3) - mx) + (-two_bx * q1 + two_bz * q3) * (two_bx * (q2q3 - q1q4) + two_bz * (q1q2 + q3q4) - my) + two_bx * q2 * (two_bx * (q1q3 + q2q4) + two_bz * (0.5 - q2q2 - q3q3) - mz);
    norm = sqrt(s1 * s1 + s2 * s2 + s3 * s3 + s4 * s4);    % normalise step magnitude
    s1 = s1 / norm;
    s2 = s2 / norm;
    s3 = s3 / norm;
    s4 = s4 / norm;
%%%%%%    
%     % compute angular estimated direction of the gyroscope error
%     g_err_x = two_q1 * s2 - two_q2 * s1 - two_q3 * s4 + two_q4 * s3;
%     g_err_y = two_q1 * s3 + two_q2 * s4 - two_q3 * s1 - two_q4 * s2;
%     g_err_z = two_q1 * s4 - two_q2 * s3 + two_q3 * s2 - two_q4 * s1;
%     
%     % compute and remove the gyroscope baises
%     g_bx = g_bx + g_err_x * deltat * zeta;
%     g_by = g_by + g_err_y * deltat * zeta;
%     g_bz = g_bz + g_err_z * deltat * zeta;
%     gx = gx - g_bx;
%     gy = gy - g_by;
%     gz = gz - g_bz;
%%%%%%
    % Compute rate of change of quaternion
    qDot1 = 0.5 * (-q2 * gx - q3 * gy - q4 * gz) - beta * s1;
    qDot2 = 0.5 * (q1 * gx + q3 * gz - q4 * gy) - beta * s2;
    qDot3 = 0.5 * (q1 * gy - q2 * gz + q4 * gx) - beta * s3;
    qDot4 = 0.5 * (q1 * gz + q2 * gy - q3 * gx) - beta * s4;

    % Integrate to yield quaternion
    q1 = q1 + qDot1 * deltat;
    q2 = q2 + qDot2 * deltat;
    q3 = q3 + qDot3 * deltat;
    q4 = q4 + qDot4 * deltat;
    
    norm = sqrt(q1 * q1 + q2 * q2 + q3 * q3 + q4 * q4);    % normalise quaternion
    result(1) = q1 / norm;
    result(2) = q2 / norm;
    result(3) = q3 / norm;
    result(4) = q4 / norm;