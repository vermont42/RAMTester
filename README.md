# Maximum RAM Usage: An iPhone-App Experiment

## Background

 I learned Objective-C and iOS-app development using CS 193P, a Stanford University course available to the public on iTunes U. From time to time, students asked Paul Hegarty, the professor, questions. One question was, to paraphrase, "What is the maximum amount of RAM that iOS will give my app before killing it?" Professor Hegarty answered, also to paraphrase, “There is no way for you to know, but you should minimize the amount of RAM that your app uses in order to prevent iOS from killing it.”

     Minimizing RAM usage is a good practice, I agree, but this answer left me unsatisfied. If, in practice, maximum RAM is much higher than the amount of RAM that my app can conceivably use, effort that could be spent on minimizing RAM usage would be better spent on other tasks. With no sense of maximum RAM, I had no idea of whether, for example, my commercially released app, Immigration, which uses no more than 40 MB  and has never been killed during testing because of excessive RAM usage, is nonetheless near the RAM limit and therefore liable to be killed on the device of a user who exposes some edge case I had not thought to test. I therefore decided to measure maximum RAM empirically on my iPhone 5S and iPhone 4S. I present my results in this blog post.

     Before I began experimenting, however, I decided to calculate theoretical maximum app RAM. The formula I came up with for this was:

physical RAM on device – OS RAM usage

iPhone 4S and  iPhone 5S have 512 MB and 1024 MB of physical RAM, respectively. To determine OS RAM usage, I took the following steps. First, I killed all running apps on the phones. Next, I ran my RAM-tester app using Xcode’s Instruments component until the OS killed the app. Finally, I added up RAM usage of all processes except the RAM-tester app. For iPhone 4S, this OS RAM usage was 125 MB. For iPhone 5S, it was 144 MB. Thus, the theoretical maximum RAMs for iPhone 4S and 5S were 387 MB and 880 MB, respectively. Surprisingly, iPhone 4S and 5S had 41 and 51 system processes, respectively. What all those processes were doing could be the subject of another blog post. Or I could just direct the reader to Jonathan Levin's book on OSX and iOS internals.

 I expected actual maximum app RAM to be lower than theoretical maximum app RAM for two reasons. First, MemoryStatus, the Mach-kernel thread that monitors RAM usage and kills apps in low-memory situations, might have some threshold below theoretical maximum RAM that causes it to start killing apps. Second, as in a hard drive, unused RAM might be non-contiguous, so an attempt to allocate a huge, contiguous chunk of RAM might fail even though that much RAM is available, albeit in non-contiguous chunks.

As I was developing the RAM-tester app, the podcatcher app, iCatcher, was playing podcasts in the background, presumably by "declar[ing] [to AVFoundation that iCatcher] plays audible content while in the background." MemoryStatus sometimes killed iCatcher before killing the RAM-tester app. MemoryStatus sometimes killed the RAM-tester app but left iCatcher alone. This iCatcher-killing surprised me for two reasons. First, it was non-deterministic. Why kill iCatcher sometimes but not all the time? Second, although iCatcher was backgrounded, it was, in some sense, "active" because it was playing podcasts, so I would have expected MemoryStatus to treat it more gingerly than other backgrounded apps, which MemoryStatus does routinely kill in low-memory situations.

## The Experiment

	I tested a variety of variables as possibly influencing maximum app RAM. I tested memory usage of NSMutableArray, NSMutableDictionary, NSData, and a combination of all three. I consider this "combination" test type the most realistic of the four because real-world apps typically use more than one data structure. I tested both iPhone 4S and 5S. Because I was unsure as to whether speed of RAM-usage increase could influence MemoryStatus's behavior, I ran my tests with no pauses, a .1-second pause every 100,000 iterations, and a .5-second pause every 100,000 iterations. I ran every test type five times, for a total of 120 test runs, and I recorded every run's RAM usage and run time in an Excel spreadsheet. The number 120 comes from the following formula:

(two device types) * (four RAM-usage scenarios) * (three pause scenarios) * (five test runs per test type)

I computed the "variance" of each run as:

absolute value (this run - average of five runs of this type)

For each set of five test runs, I computed the average variance percentage as follows:

(average variance of five test runs / average usage for this test type) * 100

     The Excel spreadsheet and the code for the RAM-tester app are available in the GitHub repository whose URL I note in the Sources section of this post. I initially wrote the code to allow triggering of specific tests via buttons, but I changed it to trigger tests in viewDidAppear: in order to prevent Instruments from measuring the time it took me to tap a button.

## iPhone 5S Results

	On iPhone 5S, average max app RAM was 536 MB. In light of the theoretical maximum app RAM of 880 MB, this result disappointed me. Where did those 344 MB go? Perhaps MemoryStatus was keeping in reserve a large chunk of unallocated RAM for possible OS usage.

            Across all sixty runs on iPhone 5S, the lowest maximum app RAM was 159 MB. This result surprised me because it was so much lower than theoretical maximum app RAM of 880 MB. This result was from a run of NSData with a .1-second pause every 100,000 iterations. I speculate that MemoryStatus threw up its (virtual) hands early on trying to reallocate a huge, contiguous chunk of memory for the NSData object.

            Across all sixty runs on iPhone 5S, the highest maximum app RAM was 747 MB. This result pleased me because it was fairly close to the theoretical maximum app RAM of 880 MB.

            The average variance percentage on iPhone 5S was 8.4%. This result pleased me because it indicated that maximum app RAM usage only varied by 8.4%. A large variance percentage would have meant that maximum app RAM usage varies greatly for a given usage scenario and that maximum RAM app usage for any particular usage scenario would therefore be difficult to predict.

            On iPhone 5S, maximum app RAM usage varied greatly depending on usage scenario. For NSMutableArray, NSData, combined, and NSDictionary, it was 364 MB, 444 MB, 596 MB, and 738 MB,  respectively. I suspect the following explains this variance. NSMutableArray may require much more contiguous RAM than NSDictionary; the contiguous-RAM requirements of NSData and the combined scenario may be intermediate. The more a data structure requires contiguity of RAM, I speculate, the more likely that data structure is to cause an out-of-memory condition.

            On iPhone 5S, average RAM-usage variance within usage scenario varied greatly, depending on the scenario. For NSDictionary, NSMutableArray, combined, and NSData, it was 1.01%, 4.43%, 5.05%, and 20.31%, respectively. The amount of RAM allocated within a particular NSDictionary, NSMutableArray, and combined scenario did not vary much. The outlier here is obviously NSData, whose variance was much larger. I noticed this outlier status as I was recording run times and ran the NSData tests in Instruments a few extra times to see what was going on. I observed that physical RAM used by the app sometimes dropped by as much as 50% before MemoryStatus killed the app. Sometimes this drop did not happen. I speculate that the RAM-contiguity requirements of NSData sometimes causes the OS to free up large chunks of RAM and reallocate them elsewhere. Intermittent failure of this process would explain the variance.

            On iPhone 5S, speed of app-RAM-usage increase did not significantly affect maximum app-RAM allocation. For no pause, .1 second per 100,000 iterations, and .5 second per 100,000 iterations, it was 546 MB, 524 MB, and 537 MB, respectively. This suggests that, on iPhone 5S, the speed of app-RAM-usage increase does not influence the behavior of MemoryStatus. Perhaps a longer pause than .5 second would affect MemoryStatus's behavior. With the longest of the sixty iPhone 5S runs taking five minutes, though, I did not test this.

## iPhone 4S Results

            On iPhone 4S, average max app RAM was 195 MB. In light of the theoretical maximum app RAM of 387 MB, this result disappointed me. As speculated above, perhaps MemoryStatus was keeping in reserve a large chunk of unallocated RAM for possible OS usage.

            Across all sixty runs on iPhone 4S, the lowest maximum app RAM was 44 MB. This result shocked me because it was so much lower than the theoretical maximum app RAM of 387 MB. Where did those 343 MB go? As with iPhone 5S, this result was from a run of NSData, albeit with no pauses. As speculated above, perhaps MemoryStatus threw up its (virtual) hands early on trying to reallocate a huge, contiguous chunk of memory for the NSData object.

            Across all sixty runs on iPhone 4S, the highest maximum app RAM was 276 MB. This result pleased me because it was within (loud) shouting distance of the theoretical maximum app RAM of 387 MB.

            The average variance percentage on iPhone 4S was 9.3%. This result pleased me because it indicated that maximum app RAM usage only varied by 9.3%. A large variance percentage would have meant that maximum app RAM usage varies greatly for a given usage scenario and that maximum RAM app usage for any particular usage scenario would therefore be difficult to predict. I further note that the average variance percentage on iPhone 4S, 9.3%, is similar to the corresponding figure on iPhone 5S, 8.4%, suggesting that iPhone 4S's memory-allocation behavior is not appreciably more unpredictable than that of iPhone 5S.

On iPhone 4S, maximum app RAM usage varied greatly depending on usage scenario. For NSMutableArray, NSData, NSDictionary, and combined, it was 130 MB, 172 MB, 229 MB, and 249 MB,  respectively. As speculated above, the differing contiguous-RAM requirements of the various data structures may explain this diversity.

            On iPhone 4S, average RAM-usage variance percentage within usage scenario varied greatly, depending on the scenario. For combined, NSDictionary, NSMutableArray, and NSData, it was 0.8%, 3.6%, 14.2%, and 18.5%, respectively. These results were similar to the iPhone 5S results in that the percentage was much higher for NSData than for combined and NSDictionary. These results differed in that the percentage for NSMutableArray was much higher than for combined and NSDictionary. I speculate that something about the more memory-constrained nature of iPhone 4S caused the NSMutableArray results to vary more on that device.

            On iPhone 4S, there appeared to be a correlation between speed of app-RAM-usage increase and maximum app-RAM allocation. For no pause, .1 second per 100,000 iterations, and .5 second per 100,000 iterations, allocations were 171 MB, 201 MB, and 212 MB, respectively. That is, as the speed of RAM allocation slowed, the ceiling for RAM allocation increased. The effect was not huge, however, and it may have resulted from the vagaries of the various test runs. Because there was no relationship between speed and ceiling on iPhone 5S, I am skeptical that such a relationship exists on iPhone 4S, but more testing may be in order here.

## Conclusions and Recommendations

            The results of my tests of RAM usage both disappointed and comforted me. They disappointed me because there is no simple answer to the question, "What is the maximum amount of RAM that iOS will give my app before killing it?" The hedgy answer is, "It depends on device type, data-structure use, possibly timing of allocations, and definitely chance." But the results comforted because the maximum RAM usages of my commercially released app, Immigration, are approximately 40 MB and 34 MB on iPhone 5S and iPhone 4S, respectively, and these usages are under the lowest ceilings I found in my testing, 159 MB and 44 MB, respectively. Thus, my app is exceedingly unlikely to ever request more RAM than iOS is willing to give it.

            My results cause me to recommend extensive RAM testing of any app that might use more than 159 MB on iPhone 5S or 44 MB on iPhone 4S.  I would attempt to reduce RAM usage of any app that exceeds these limits, and I would redouble these efforts for any app whose usage approaches the average ceilings of 536 MB and 195 MB on iPhone 5S and iPhone 4S, respectively. Unlike, say, Infinity Blade III, my app is not graphics-intensive, and it is therefore unlikely to ever be RAM-constrained. I suspect that the uncertainty of max RAM is frustrating for developers of apps that do push the limits of RAM availability. Those developers would be well-advised to pay careful attention to didReceiveMemoryWarning: and quickly reduce RAM usage when that method is invoked.

            The lower RAM ceilings of NSData and NSMutableArray, as compared to NSDictionary, suggest that developers should be especially careful with enormous NSDatas and NSMutableArrays. Custom reimplementations of those two classes might result in some benefit because thrifty RAM usage was presumably only one of multiple, competing requirements that Apple considered in its implementations of those classes. But because "premature optimization is the root of all evil", such reimplementations should only occur after extensive RAM testing in Instruments.

## Sources

[CS 193P](https://itunes.apple.com/us/course/developing-ios-7-apps-for/id733644550)

My commercially released app, [Immigration](http://www.immigrationapp.biz)

[Amount of RAM on iPhone 4S and 5S](http://9to5mac.com/2013/09/19/iphone-5s-a7-chip-only-dual-core-but-its-still-the-fastest-phone-out-there/)

[iCatcher!](http://joeisanerd.com/apps/icatcher) (note the exclamation point)

Playing media while in the background using [AVFoundation](https://developer.apple.com/library/ios/qa/qa1668/_index.html)

Jonathan Levin's [book](http://newosxbook.com) on OSX and iOS internals

How iOS [manages](http://newosxbook.com/articles/MemoryPressure.html) low-memory situations 

[“premature optimization is the root of all evil”](http://c2.com/cgi/wiki?PrematureOptimization)

The other iPhone-app experiment: http://www.iphoneappexperiment.com