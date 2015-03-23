EyeJS Trial and Evaluation
==========================

## Trial Format

Trial participants will be asked to participate in a series of experiments. Each experiment will be performed by each user three times; once using a standard mouse, once using EyeJS with keypress activation, and once using EyeJS blink activation. The order of the experiments and the order of the input modes they use to complete the task (mouse, keypress, blinking) will be randomized.

### Input Modes

There are three distinct input modes for this trial. The keyboard will be used for text entry in all three modes.

#### Mouse ($m$)

In this input mode, the trial participants will use a standard mouse to select elements. This will be considered the *baseline case* that EyeJS is compared to.

#### Keypress ($k$)

In this input mode, elements are selected using a keyboard keypress using EyeJS. Users gaze at a particular elements (which is essentially analogous to a mouse *hover*), then press a key on the keyboard to select it.

#### Blinks  ($b$)

Elements are selected using EyeJS blink-selection. In this mode, users gaze at a particular element and use a specially timed blink to select elements.

### Experiments Overview

Each participant will complete four experiments. The experiment procedure will be repeated three times with each participant, once for each input mode.

#### Sythetic User Interface ($s$)

This experiment will measure the user's accuracy and execution time when presented with a sequence of selection tasks.

#### Simple Navigation ($w$)

This experiment will measure the difference in task execution time between different modes of input on a simple website (Wikipedia.org).

#### Complex Navigation ($a$)

This experiment will measure the difference in task execution time between different modes of input on a complex and link-dense website (Amazon.com).

#### User Focus ($f$)

This experiment will measure the amount of information gathered and retained by the user with and without custom eye-aware UI enhancements using EyeJS.

### Participant Randomization

The order in-which participants complete experiments will be randomized, as well as the order of input modes they use. An example of participant experiment and input mode assignments are below. The experiment cells are tuples, the first element representing which experiment is being performed and the second the order of input modalities.

| Participant        | First Experiment  | Second Experiment | Third Experiment  | Fourth Experiment |
| ------------------ | :---------------: | :---------------: | :---------------: | :---------------: |
| John               | $ (s, kmb) $      | $ (w, kbm) $      | $ (f, mkb) $      | $ (a, bkm) $      |
| Jane               | $ (w, mbk) $      | $ (s, mkb) $      | $ (a, mbk) $      | $ (f, kbm) $      |
| Mike               | $ (a, kbm) $      | $ (w, kbm) $      | $ (f, kmb) $      | $ (s, kmb) $      |


## Things to Avoid

### Don't Evaluate the Webpage

We don't want to evaluate the design or usability of the webpages used during this trial. Only the amount of time taken to *select* navigation elements, and selection accuracy should be considered, not the amount of time taken to *locate* the navigation element.



## Questions to Answer

### Primary Questions

- How does user accuracy change when using EyeJS compared to a standard mouse?
- How does using EyeJS affect the speed of task completion?
- When using EyeJS, are keypress activations more accurate than blinks?
- When using EyeJS, how does activation time compare between using keypresses and blinks?
- How small can buttons and other interactive elements get before accuracy and selection ability start to degrade?
- How close can interactive elements get before accuracy and selection ability start to degrade?

### Secondary Question

- How large should the gaze area (gaze indicator) be?
- Does automatic page scrolling decrease the amount of time it takes for users to perform the tasks? **[Should we add an experiment for automatic page scrolling?]**



## Assumptions and Parameters

### Gaze Area

The gaze area is a circular area where DOM sample points are taken by EyeJS. The samples are taken in an outward, counter-clockwise radiating pattern.

![](images/gaze-area.svg)

### Fixation Time

We consider a *fixation* to have occurred after the longest possible saccade (in duration). So, if the user's gaze remains over a specific element for a greater period of time than the longest saccade, then we consider this a fixation of that element. Eye tracker samples which indicate the user's gaze is over a specific element, but do not sample that same element for longer than some fixation threshold are ignored.

![](images/saccade-ignore.svg)

We define the *fixation threshold*, $\delta$, as minimum amount of time the user's gaze must be continually over an element for a *fixation* to occur.

$$ \delta = Fixation\ Threshold > Longest\ Saccade\ Duration = 120 ms $$

We assume that after the user has *fixated* on the target element, the user is aware of it's presence. In situations where the user's only goal is to select the target element, further fixations indicate gazing away from the target for some reason, or trouble selecting the target. The interpretation of this may change as data is available from the audio and video recording of the user. If a fixation is recorded but the user indicates in the audio or video recording that they are unaware of the element (e.g. a recorded fixation of a target button, but the user continues searching), then the fixation(s) should be recorded as *false fixations*. Many false fixations may indicate a problem recording fixations or that an adjustment is required to fixation detection methods or parameters.




## Data and Measurements

A variety of data will be logged during each trial to analyze EyeJS performance and how the user interacted with the computer using EyeJS.

### Mouse Movements and Clicks

Mouse movements and clicking will be logged so we can compare those data to eye-tracking data when the user is using the mouse. *(e.g. How long does it take for the user to click an element after they have fixated on it?)*

### User Audio and Video

Video will be recorded using a webcam and synced with the trial. Using the recorded video we can gain insight into what the user's intent was, comparing that with the observed eye tracking and mouse data.

### Eye Tracking Measurements

All eye tracking data will be logged even if the user is currently interacting via the mouse. This will allow us to compare EyeJS interaction with that of the standard mouse. Eye activity will be logged and synced separately from EyeJS for later for analysis.

![](images/eye-measurements.svg)

#### Task Time

Generally, we are concerned with how long it takes the user to select some element (i.e. a button or anchor) using their assigned input mode (mouse, blinking, or keypress). This can be measured by observing the time between element activations within the task. In the diagram above, this would correspond to the difference between the last element activation (or first task start) and the target element's activation.

We define *Task Time* for the $i ^{th}$ task of an experiment as $T_{i}$, according to the diagram above as follows:

$$ T \_{i} = t\_{end} - t\_{start} $$

#### Number of Fixations

We are also interested in the number of times the user fixates on a target element. A selection with a singular fixation indicates the user looked at the target element and selected it without changing their gaze. This is probably an ideal scenario, and it is likely that the user will shift their gaze before activating the element. For example this could happen when they are using the mouse if they quickly shift their gaze to locate their cursor before activating the element. Also, this could be observed when activating an element using a keypress, if the user quickly looks at the keyboard to confirm they are about to press the correct key.

The above diagram shows a series of fixations over a target element, indexed $0...n-1$. We will record all fixations of all elements as the set $F$ and fixations over the target element as set $Q$. We are specifically interested in measuring the number of fixations over the target element, $\left| Q \right| = n$, but we are also interested in the total number of fixations, $\left| F \right|$.

#### Length of Fixations

Fixations will be recorded as tuples consisting of the element the user is fixated on and the start and end times, so for some fixation $f$,

$$ f = (f\_{element}, f\_{start}, f\_{end}) = (fixated\ element, fixation\ start\ time, fixation\ end\ time) $$

Measuring the length of each fixation will help us determine if the user dwells on a target for differing lengths of time depending on which mode of input they are using. This is measured as the difference in time between when the fixation starts, and when it ends. This time will always be greater than $\delta$.

#### Time from First Fixation

How long does it take for the user to select an element after their first fixation, regardless of the number of fixations? Since we can be assured the user intended to select the element during the last fixation, if there is a significant difference between the *Time from Last Fixation* and the *Time from First Fixation*, we should investigate if the fixations are being erroneously recorded.

$$ T\_{i\_{ff}} = t\_{end} -  f\_{0\_{start}} $$

#### Time from Last Fixation

Measuring from the start of the last fixation, how long does it take the user to select the element? If there is only a single fixation, then this will be the same as *Time from First Fixation*. This tells us how long the user dwells on an object before activating it. For example, if the user is using a mouse, this will indicate how long it takes for the user to get the mouse over the target and select it, while still dwelling on the target.

$$ T\_{i\_{lf}} = t\_{end} -  f\_{n-1\_{start}} $$

#### Away Time

This is the time between the last fixation and when the user select the element. If using blinks, this time corresponds to the blink activation time. If using keypresses, this could represent the user looking away from the screen and to the keyboard.

$$ T\_{i\_{at}} = t\_{end} -  f\_{n-1\_{end}} $$

### Accuracy

User selection accuracy, $A$ will be measured as the ratio of intended element selections to total element selections for the $i\^{th}$ experiment.

$$ A\_{i} = \frac{Intended\ Selections}{Total\ Selections} $$

For most tasks, the intended selection will be clear from the directions given to the user. If it is unclear, then the video and audio records of the user will be used to determine what their intention was.

## Experiments

### Synthetic User Interface

This experiment present to the user a synthetic user interface, and will measure and compare the efficacy of the user when using the standard mouse versus EyeJS.

#### Task Description

This task will present the user with a screen of uniformly sized buttons and a sequence of capital letters. Each button will be randomly labeled by a single capital letter. The user must select the buttons in a specific, randomly generated sequence. As the trial continues, the size of the buttons will decrease and the distance between them will change.

![](images/button-layout.svg)

#### Things to Consider

- The difference in speed and accuracy of the user when using EyeJS versus a standard mouse.
- How size and density of interactive elements affect the speed and accuracy of the user.
- How the gaze area (size of the gaze indicator) affects the user's speed and accuracy.
- What is a reasonable link-density when using designing eye-ui's?

#### What's Changing

During this experiment, the following parameters will change: the size of the buttons, the margin between the buttons, and the size of the gaze indicator.

##### Button Size ($\beta$)

The size of the buttons will progressively decrease: each stage reduces the button size by a factor of $\lambda$. For instance, if $\lambda = \frac{3}{4}$ and the buttons start at 100x100 pixels, the second stage will feature buttons of 75x75 pixels, and the next 56x56 pixels, 42x42, 31x31, and so on.

![](images/changing-button-size.svg)

##### Button Margin ($\mu$)
The distance between interactive elements is expected to affect the accuracy of the user. Therefore, for each stage we will vary the distance between the buttons that the user must select. An example margin sequence (in pixels) is 100, 75, 50, 25, 10, 5.

##### Gaze Indicator Size ($\xi$)
Once the user's accuracy has decreased below 50%, or the median time between selections has doubled, the size of the gaze indicator will be modified in an attempt to increase the user's accuracy or decrease the user's selection time.

![](images/gaze-indicator-size.png)

#### Experiment Completion

This experiment will be considered complete when the user's accuracy falls below 50%, or the task time increases by 100% as measured from the first completed task.


### Simple Navigation (Wikipedia.org)

This task measures the user's ability to navigate a simple website and locate and extract specific information from the site.

#### Things to Consider

- How does automatic scrolling affect the user's navigation ability and speed of navigating the page?
- Does the link-highlighting distract the user from the information they are seeking?

#### Task Sequence

The user will start the experiment at [http://wikipedia.org](http://wikipedia.org).

1. Select **English**.
2. Select the **Science** portal.
3. Preview the *Selected Picture*.
4. Close the *Selected Picture* preview.
5. Select the *Search* field in the header.
6. Type-in `UCSD` into the search field.
7. Extract the following information, based on the input mode sequence.
7.1. (First Input Mode) Find and read aloud the number of undergraduate students enrolled at UCSD.
7.2. (Second Input Mode) Find and read aloud the campus size in acres.
7.3. (Third Input Mode) Find and read aloud the size of the endowment.
8. Navigate to *Global Rankings* using the *Content* link area.
9. Extract the following information, based on the input mode sequence.
9.1. (First Input Mode) Find and read aloud the *Washington Monthly* ranking of UCSD
9.2. (Second Input Mode) Find and read aloud the *ARWU* ranking of UCSD
9.3. (Third Input Mode) Find and read aloud the *U.S. News & World Report* ranking of UCSD



### Complex Navigation (Amazon.com)

#### Things to Consider

- Can the user navigate a link-dense environment like Amazon.com?
- Are they able to discover that they can select videos by looking at them, and pressing the *select* button?
- Does image *zooming* distract the user?

#### Task Sequence

The user will start the experiment at [http://amazon.com](http://amazon.com).

1. Select **Shop by Department**
2. Select **Movies, Music & Games** > *Movies & TV*
3. Select the **New Releases**
4. Under the *Browse Releases by Week* section, select the most recently reelased film.
5. Select the cover image, previewing it in full screen.
6. Close the cover image preview.
7. Extract the following information, based on the input mode sequence.
7.1 (First Input Mode) Find and read aloud the name of the person who posted the second most-helpful review.
7.1 (Second Input Mode) Find and read aloud the date of the most helpful customer review.
7.1 (third Input Mode) Find and read aloud the format of the third most-helpful customer review.



### Reading Comprehension with Fading Sidebar

This task will utilize a [Cloze Test](http://en.wikipedia.org/wiki/Cloze_test) to measure how well the user can assimilate content from a page with potentially distracting sidebar elements. Using EyeJS, we will fade other elements from the page while the user is reading main content text, only bringing them fulling into view when the user is looking at them. We are interested in determining if fading non-relavent information helps the user absorb task-related information faster or more accurately.

This experiment will be conducted twice with each user. Both times the user will use a standard mouse for input. One time, the sidebar will be in full-view and will not respond to user gaze. While the other, the sidebar will fade in-and-out based on the user's gaze. The order in-which the user's conduct the tasks (fading vs. not-fading) will be randomized.

When the user has completed the Cloze portion of the test, the use will be directed to press a *Done* button in the sidebar.

#### Things to Consider

- Does fading non-relavent sidebar information with potentially distracting content help the user absorb task-related information more quickly and accurately?



### Natural Use
