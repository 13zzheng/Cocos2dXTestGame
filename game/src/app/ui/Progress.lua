--
-- Author: Your Name
-- Date: 2017-06-07 13:04:23
--

local Progress = class("Progress", function(background, fill)
	local progress = display.newSprite(background)

	local fill = display.newProgressTimer(fill, display.PROGRESS_TIMER_BAR)
	progress.fill = fill
	--设置进度条的起点
	fill:setMidpoint(CCPoint(0, 0.5))
	--设置进度条变化速度
	fill:setBarChangeRate(CCPoint(1.0, 0))
	fill:setPosition(progress:getContentSize().width/2, progress:getContentSize().height/2)
	--设置进度条的进度
	fill:setPercentage(100)

	progress:addChild(fill)

	return progress
end)


function Progress:ctor()

end


function Progress:setProgress(progress)
	self.fill:setPercentage(progress)
end

return Progress