# Enable threshold monitoring
EXTRA_OECMAKE_append_sh5 = "-DSEL_LOGGER_MONITOR_THRESHOLD_EVENTS=ON \
                            -DSEL_LOGGER_MONITOR_THRESHOLD_ALARM_EVENTS=ON \
                           "