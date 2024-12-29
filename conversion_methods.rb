def chord_to_number(chord, scale)
  note_to_number = {
    'C' => 3, 'C#' => 3.5, 'Db' => 2.5, 'D' => 4, 'D#' => 4.5, 'Eb' => 3.5, 'E' => 5, 'Fb' => 4.5,
    'F' => 6, 'F#' => 6.5, 'Gb' => 5.5, 'G' => 0, 'G#' => 0.5, 'Ab' => 6.5, 'A' => 1, 'A#' => 1.5, 
    'Bb' => 0.5, 'B' => 2, 'Cb' => 1.5, 
  }

  scale_note = scale.gsub(/m|#/,'')
  scale_num = note_to_number[scale_note]

  chord_symbols = ['m', 'aug', 'dim','M', '7', '9', '-5', '6', '♮11']
  symbols_pattern = chord_symbols.join('|')
  chord_note = chord.gsub(/#{symbols_pattern}/, '')
  code_num = note_to_number[chord_note]

  result_num = (code_num - scale_num) % 7

  symbols_found = chord_symbols.select { |symbol| chord.include?(symbol) }
  result_num = "#{result_num}#{symbols_found.join}"

  result_num
end

def number_to_roman_major(codename)
  roman_numerals_major = {
    '0m' => '-I', '1dim' => '◦I', '1m' => 'II', '2m' => 'III', '3m' => '-IV', '4m' => '-V', '5m' => 'VI', '6dim' => 'VII',
    '6m' => '+VII', '1.5m' => '-◦III', '4.5m' => '-◦VI', '5.5m' => '-◦VII', '6m-5' => 'VII', '0' => 'I', '1' => '+II',
    '2' => '+III', '3' => 'IV', '4' => 'V', '5' => '+VI', '6' => 'VII', '1.5' => '◦III', '4.5' => '◦VI', '5.5' => '◦VII',
    '0M' => 'I','3M' => 'IV', '6' => '++VII', '3.5' => '↥VI'
  }

  other_symbols = {
    '7' => '7', '9' => '9', 'aug' => '’', '-5' => '`', '+6' => '+6', '♮11' => '+4'
  }

  codename = codename.to_s  # codenameを文字列として処理

  # 文字数が多い順に並び替えてから置換する
  roman_numerals_major.sort_by { |k, v| -k.to_s.length }.each do |key, value|
    if codename.start_with?(key)
      codename = codename.sub(key, value)
      break
    end
  end

  other_symbols.each do |symbol, conversion|
    if codename.include?(symbol)
      codename = codename.gsub(symbol, conversion)
    end
  end

  codename
end

def number_to_roman_minor(codename)
  roman_numerals_minor = {
    '0m' => 'I', '1dim' => 'II', '2' => 'III', '3m' => 'IV', '4m' => 'V', '5' => 'VI', '6' => 'VII',
    '0' => '+I', '2m' => '-III', '3' => '+IV', '4' => '+V', '5m' => '-VI', '6m' => '-VII',
    '1m' => '▵I', '2.5m' => '▵III', '5.5m' => '▵VI', '6.5dim' => '▵VII', '0.5' => '-II',
    '1' => '+▵I', '2.5' => '+▵III', '5.5' => '+▵VI','2M' => 'III','5M' => 'VI'
  }

  other_symbols = {
    '7' => '7', 'b9' => '9', 'aug' => '’', '-5' => '`', '6' => '+6', '#11' => '+4'
  }

  codename = codename.to_s  # codenameを文字列として処理

  # 文字数が多い順に並び替えてから置換する
  roman_numerals_minor.sort_by { |k, v| -k.to_s.length }.each do |key, value|
    if codename.start_with?(key)
      codename = codename.sub(key, value)
      break
    end
  end

  other_symbols.each do |symbol, conversion|
    if codename.include?(symbol)
      codename = codename.gsub(symbol, conversion)
    end
  end

  codename
end

def number_to_roman(codename, scale)
  if scale.include?('m')  # スケールがマイナーの場合
    number_to_roman_minor(codename)
  else  # スケールがマイナーの場合
    number_to_roman_major(codename)
  end
end


def code_to_code(r1, r2)
  set1 = [["I", "III"], ["I", "VI"], ["II", "IV"], ["II", "VII"], ["III", "V"], ["IV", "VI"], ["V", "VII"]]
  set2 = [["I7", "III7"], ["I7", "VI7"], ["II7", "IV7"], ["II7", "VII7"], ["III7", "V7"], ["IV7", "VI7"], ["V7", "VII7"]]
  pair1 = [["V", "I"], ["VI", "II"], ["VII", "III"], ["I", "IV"], ["II", "V"], ["III", "VI"], ["IV", "VII"]]
  pair2 = [["II", "I"], ["III", "II"], ["IV", "III"], ["V", "IV"], ["VI", "V"], ["VII", "VI"], ["I", "VII"]]
  pair3 = [["I", "II"], ["II", "III"], ["III", "IV"], ["IV", "V"], ["V", "VI"], ["VI", "VII"], ["VII", "I"]]

  # 記号を取り除く
  symbols = ["+", "-", "◦", "▵", "↥", "7", "9", "`", "’", "+6", "+4"]
  clean_r1 = r1.chars.reject { |c| symbols.include?(c) }.join
  clean_r2 = r2.chars.reject { |c| symbols.include?(c) }.join

  if set1.include?([clean_r1, clean_r2].sort)
    return '=2'
  elsif set2.include?([clean_r1, clean_r2].sort)
    return '=3'
  elsif pair1.any? { |pair| clean_r1 == pair[0] && clean_r2 == pair[1] }
    return '- 5'
  elsif pair2.any? { |pair| clean_r1 == pair[0] && clean_r2 == pair[1] }
    return '-1'
  elsif pair3.any? { |pair| clean_r1 == pair[0] && clean_r2 == pair[1] }
    return '+1'
  else
    return '---'
  end
end
