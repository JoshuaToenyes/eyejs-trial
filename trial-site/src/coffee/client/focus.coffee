$ ->
  OFF_OPACITY = 0.1

  #
  # Correct:
  # 1) right
  # 2) mind
  # 3) tears
  # 4) heads
  # 5) gloves
  # 6) feet
  # 7) shrinking


  content1 = "<p>'I'm sure those are not the _____ words,' said poor Alice, and
  her eyes filled with tears again as she went on, 'I must be Mabel after all,
  and I shall have to go and live in that poky little house, and have next to
  no toys to play with, and oh! ever so many lessons to learn! No, I've made
  up my ____ about it; if I'm Mabel, I'll stay down here! It'll be no use their
  putting their heads down and saying \"Come up again, dear!\" I shall only
  look up and say \"Who am I then? Tell me that first, and then, if I like
  being that person, I'll come up: if not, I'll stay down here till I'm
  somebody else\"—but, oh dear!' cried Alice, with a sudden burst of _____,
  'I do wish they would put their _____ down! I am so very tired of being
  all alone here!'</p>

  <p>As she said this she looked down at her hands, and was surprised to see
  that she had put on one of the Rabbit's little white kid ______ while she
  was talking. 'How can I have done that?' she thought. 'I must be growing
  small again.' She got up and went to the table to measure herself by it,
  and found that, as nearly as she could guess, she was now about two ____
  high, and was going on shrinking rapidly: she soon found out that the cause
  of this was the fan she was holding, and she dropped it hastily, just in
  time to avoid _________ away altogether.<p>"

  #
  # Correct:
  # 1) little
  # 2) child
  # 3) slipped
  # 4) water
  # 5) fallen
  # 6) Alice
  # 7) tears

  content2 = "<p>'That was a narrow escape!' said Alice, a good deal frightened
  at the sudden change, but very glad to find herself still in existence;
  'and now for the garden!' and she ran with all speed back to the little door:
  but, alas! the _____ door was shut again, and the little golden key was
  lying on the glass table as before, 'and things are worse than ever,'
  thought the poor _____, 'for I never was so small as this before, never!
  And I declare it's too bad, that it is!'</p>

  <p>As she said these words her foot ______, and in another moment, splash!
  she was up to her chin in salt ____. Her first idea was that she had
  somehow ______ into the sea, 'and in that case I can go back by railway,'
  she said to herself. (_____ had been to the seaside once in her life, and
  had come to the general conclusion, that wherever you go to on the English
  coast you find a number of bathing machines in the sea, some children
  digging in the sand with wooden spades, then a row of lodging houses,
  and behind them a railway station.) However, she soon made out that she
  was in the pool of _____ which she had wept when she was nine feet high.</p>"

  fadingEnabled = /with\-fading/.test window.location.search

  if fadingEnabled
    $('aside').css 'opacity', OFF_OPACITY

    $('aside').on 'gaze', ->
      $(this).css 'opacity', 1

    $('aside').on 'gazeleave', ->
      $(this).css 'opacity', OFF_OPACITY

    $('#content').html content1

  else
    $('aside').css 'opacity', 1

    $('#content').html content2
