#pragma once

#include <QtCore>

namespace atomic_dex
{
    struct ma_series_data
    {
        qint64 m_timestamp;
        double m_average;
    };
}