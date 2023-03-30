@def title="Neutral Point"

\note{Objective}{Investigate ways to quantify an "experiential neutral point", the threshold at which life is worth experiencing.}



\tableofcontents

## Collecting the Data
I went through a few iterations of surveys over time. They were all written in [Guided Track](https://www.guidedtrack.com/) and participants were recruited through [Positly](https://www.positly.com/), both fantastic platforms.

In general, surveys are framed around 3 questions:
 - **How satisfied are you with life as a whole these days?**
    - This is the question that underpins the [WELLBY metric](https://www.happierlivesinstitute.org/report/estimating-moral-weights/)
 - **How enjoyable is your life as a whole these days?**
 - **Do you expect tomorrow to be worth experiencing?**

@@full-width
~~~
<table>
  <tbody>
    <tr>
      <th>Guided Track Survey</th>
      <th>Guided Track Code</th>
      <th>n</th>
      <th>Data</th>
      <th>Questions</th>
    </tr>

    <tr style="text-align: center;">
      <td style="text-align: center;"><a href="https://www.guidedtrack.com/programs/9dmdvic/run">link</a></td>
      <td><a href="/projects/neutral_point/np_survey_5.txt">np_survey_5.txt</a></td>
      <td>106</td>
      <td><a href="/projects/neutral_point/np_data_5.csv">np_data_5.csv</a></td>
      <td>
        How satisfied are you with life as a whole these days?<br><br>
        How enjoyable is your life as a whole these days?<br><br>
        Imagine I gave you a "REPLAY YESTERDAY" button. When pressed, this button would cause you to be instantly transported back in time to yesterday morning. You would live the day again exactly the same as you did the first time. You would have no recollection of pressing the button. *Would you press this button to replay yesterday?*<br><br>
        Imagine I gave you a "SKIP TOMORROW" button. When pressed, this button would cause you to be instantly transported 24 hours into the future. You still do all the things you would normally do (so nobody else can tell any difference), and remember the day normally, you just don't experience it. Afterwards, you forget you pressed the button. *Would you press this button to skip tomorrow?*
      </td>
    </tr>

    <tr style="text-align: center;">
      <td style="text-align: center;"><a href="https://www.guidedtrack.com/programs/nlb2gvj/run">link</a></td>
      <td><a href="/projects/neutral_point/np_survey_4.txt">np_survey_4.txt</a></td>
      <td>704</td>
      <td><a href="/projects/neutral_point/np_data_4.csv">np_data_4.csv</a></td>
      <td>
        How satisfied are you with life as a whole these days?<br><br>
        How enjoyable is your life as a whole these days?<br><br>
        Imagine I gave you a "SKIP TOMORROW" button. When pressed, this button would cause you to be instantly transported 24 hours into the future. You still do all the things you would normally do (so nobody else can tell any difference), and remember the day normally, you just don't experience it. Afterwards, you forget you pressed the button. *Would you press this button to skip tomorrow?*
      </td>
    </tr>

    <tr style="text-align: center;">
      <td style="text-align: center;"><a href="https://www.guidedtrack.com/programs/szolb82/run">link</a></td>
      <td><a href="/projects/neutral_point/np_survey_3.txt">np_survey_3.txt</a></td>
      <td>113</td>
      <td><a href="/projects/neutral_point/np_data_3.csv">np_data_3.csv</a></td>
      <td>
        How satisfied are you with life as a whole these days?<br><br>
        How enjoyable is your life as a whole these days?<br><br>
        How enjoyable do you expect tomorrow to be?<br><br>
        Imagine I gave you a "SKIP TOMORROW" button. When pressed, this button would cause you to be instantly transported 24 hours into the future. You still do all the things you would normally do (so nobody else can tell any difference), and remember the day normally, you just don't experience it. Would you press this button to skip tomorrow?<br><br>
        What level of expected enjoyment do you think would be your threshold for pressing the button?
      </td>
    </tr>

    <tr style="text-align: center;">
      <td style="text-align: center;"><a href="https://www.guidedtrack.com/programs/y76qix7/run">link</a></td>
      <td><a href="/projects/neutral_point/np_survey_2.txt">np_survey_2.txt</a></td>
      <td>117</td>
      <td><a href="/projects/neutral_point/np_data_2.csv">np_data_2.csv</a></td>
      <td>
        How satisfied are you with life as a whole these days?<br><br>
        How enjoyable is your life as a whole these days?<br><br>
        Imagine I gave you a "SKIP TODAY" button. When pressed, this button would cause you to be instantly transported 24 hours into the future. You still do all the things you would normally do, and remember the day normally, you just don't experience it. In a typical week how many times would you use the button?
      </td>
    </tr>

    <tr style="text-align: center;">
      <td style="text-align: center;"><a href="https://www.guidedtrack.com/programs/zslhfq3/run">link</a></td>
      <td><a href="/projects/neutral_point/np_survey_1.txt">np_survey_1.txt</a></td>
      <td>100</td>
      <td><a href="/projects/neutral_point/np_data_1.csv">np_data_1.csv</a></td>
      <td>
        If you could press a button to skip tomorrow, would you? Assume you still complete all the things you would normally complete, and remember the day normally, you just don't experience it.<br><br>
        How satisfied are you with life as a whole these days? <br><br>
        How enjoyable is your life these days?
      </td>
    </tr>
  </tbody>
</table>
~~~
@@

## Exploring the Data

@@im-100
\fig{/projects/neutral_point/summary_hists.svg}
@@

Our median (modal*) user:
 - Completed the 3 question survey in 25 seconds
 - 38 years old
 - Male*
 - Currently employed*
 - Completed a Bachelor's degree
 - Credit score is Good: 670 - 739
 - Politically moderate
 - Household yearly income between \$60K and \$85K
 - In a long term relationship*
 - Uses social media for 45 minutes each day
 - Slightly religious
 - Average physical health
 - Never diagnosed with a mental health disorder*
 - Life satisfaction these days is 6/10
 - Life enjoyment these days is 6/10
 - Would not choose to skip tomorrow*


@@im-100
\fig{/projects/neutral_point/summary_correls.svg}
@@

Some initial non-intuitive correlations:
 - Age is inversely correlated with the probability of skipping tomorrow
 - Education is correlated with life satisfaction and enjoyment, but it does not make you want to skip tomorrow any less
 - Liberalness is inversely correlated with life satisfaction and enjoyment, but not with the probability of skipping tomorrow


@@im-100
\fig{/projects/neutral_point/enjoy_skip_bars.svg}
@@

The fraction of people that would skip tomorrow starts around 40% at the low enjoyment end and decreases relatively linearly to around 5% at a 10/10.

One way of interpreting this data is that at no point on the enjoyment scale is life worth skipping, because at no point do the majority of people answer "yes" to the question of skipping tomorrow.

Another way of interpreting this data is that each point traversed on the enjoyment scale nets a (40%-5%) / 10 = 3.5% increase in the likelihood of wanting to experience tomorrow. Naively, this might be interpreted as saying that buying 29 points in life enjoyment is equivalent, in expectation, of buying one 

## Next Steps
 - Survey participants in different geographies

## Ingredients
 - [Guided Track](https://www.guidedtrack.com/) - Survey build and hosting platform
 - [Positly](https://www.positly.com/) - Recruit, screen, survey, message, re-target and compensate survey participants 