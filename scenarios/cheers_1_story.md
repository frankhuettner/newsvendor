
![](https://c.pxhere.com/photos/08/40/bake_pastries_pastry_petits_fours_frais_small_oven_chocolate_cream_fruits-1021221.jpg!d)

## Patisserie *Cheers!* 


A few years ago, Kay and Lucilla established their patisserie Cheers! and this year’s season has started out well. However, they still can’t agree on how to deal with a serious problem they've been facing since the very beginning. 

The cakes they make are of the highest quality and thus come at a high price, both for them as producers, and also for their customers, who pay € 5 for each artisanal mini cake that Cheers! produces. But their customers appear content with this price, as they tend to keep coming back for more. Multiple regular clients have said their prices are justified given the quality of ingredients, the freshness of the cakes, and the service that Kay and Lucilla provide.

After a long day with very few customers, Kay had still some work to do. Recently, they signed up for a service that organizes the donation of leftover food to people in need. Her last task of that day was to put the 28 cakes that were left over into a box, and to wait for the courier to come pick it up.

While waiting, Kay and Lucilla fell into their familiar argument about how many cakes they should be producing each day. Lucilla stressed that the excess they’re donating today isn’t such a big loss. "It only cost about € 1 to produce a cake." But Kay hated that they worked so hard to craft these cakes and then saw nothing in return. Lucilla countered that it hurts even more when they have to turn customers away because they sell out.

Kay was motivated to discuss the issue again. Sitting at her laptop, she scrambled up the sales data from the past year. Even though they sell out almost every other day (they prepared 100 cakes each day), the fluctuation of customers was a serious problem and let to a lot of leftover cakes. Putting the sales data into a histogram made this very clear.

![](https://github.com/frankhuettner/newsvendor/blob/main/scenarios/img/cheers_1_story_histogram.svg?raw=true)

At first she was confused about the shape of the figure. Then she realized that sales were capped at 100. The spike between 95 and 105 cakes included all the days when they sold out. On all other days, they had cakes left over.

Kay was convinced that the graph resembles a bell curve, as if demand is randomly drawn from a normal distribution. She was not only an excellent creator of mini cakes but also a very creative solver of problems and she googled right away on how to plot a bell curve in Excel. Moving it above the histogram, the combined picture looked best with the mean parameter μ = 90 and the standard deviation parameter σ = 30.

![](https://github.com/frankhuettner/newsvendor/blob/main/scenarios/img/cheers_1_story_histogram_with_curve.svg?raw=true)

In view of the data, Kay felt reassured. "Look, we should make 90 cakes each day -- it's our best bet to meet demand. Making 100 is a waste!" Lucilla had a different reaction to the analysis. Trying to make sense of what she saw, she remembered the [68–95–99.7 rule](https://en.wikipedia.org/wiki/68%E2%80%9395%E2%80%9399.7_rule). Applied to their sales numbers, it means that demand happens to be below 60 or above 120 on 32% of the days. It was then that she begun to grasp the uncertainty pervading their business and -- being their only source of income -- their lives, accompanied by a paralyzing feeling she usually keeps tucked away. Rather resignedly, she concluded that "unless we become fortune tellers, there's nothing we can do. Where there's no solution, there is no problem."
