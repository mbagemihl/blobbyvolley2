/*=============================================================================
Blobby Volley 2
Copyright (C) 2006 Jonathan Sieber (jonathan_sieber@yahoo.de)
Copyright (C) 2006 Daniel Knobe (daniel-knobe@web.de)

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
=============================================================================*/

/* header include */
#include "Clock.h"

/* includes */
#include <sstream>
#include <cstdio>
#include <algorithm>

/* implementation */

namespace {
	template<class T>
	Clock::seconds to_seconds(T input) {
		return std::chrono::duration_cast<Clock::seconds>(input);
	}
}

void Clock::reset()
{
	// set all variables to their default values
	mRunning = false;
	mGameRunning = duration_t(0);
	mLastTime = clock_t::now();
	mCurrentTimeString = "00:00.00";
}

void Clock::start()
{
	mLastTime = clock_t::now();
	mRunning = true;
}

void Clock::stop()
{
	mRunning = false;
}

bool Clock::isRunning() const
{
	return mRunning;
}

Clock::seconds Clock::getTime() const
{
	return to_seconds(mGameRunning);
}

int Clock::getTimeMs() const
{
	return static_cast<int>(std::chrono::duration_cast<Clock::milliseconds>(mGameRunning).count());
}

void Clock::setTime(milliseconds newTime)
{
	updateGameTime(newTime);
}

std::string Clock::formatTimeMs(int time_ms)
{
	int clamped_ms = std::max(0, time_ms);
	int centiseconds = (clamped_ms / 10) % 100;
	int seconds = (clamped_ms / 1000) % 60;
	int minutes = (clamped_ms / 60000);

	char buffer[32];
	std::snprintf(buffer, sizeof(buffer), "%02d:%02d.%02d", minutes, seconds, centiseconds);
	return std::string(buffer);
}

std::string Clock::makeTimeString(seconds time)
{
	return formatTimeMs(static_cast<int>(time.count()) * 1000);
}

const std::string& Clock::getTimeString() const
{
	return mCurrentTimeString;
}

void Clock::step()
{
	if(mRunning)
	{
		auto newTime = clock_t::now();
		updateGameTime(mGameRunning + (newTime - mLastTime));
		mLastTime = newTime;
	}
}

void Clock::updateGameTime(duration_t new_time) {
	mGameRunning = new_time;
	mCurrentTimeString = formatTimeMs(getTimeMs());
}