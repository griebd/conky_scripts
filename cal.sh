#!/usr/bin/bash

# for this to work correctly it's necessare to increase text_buffer_size in
# .conkyrc

# example of use
# ${execpi 2 ~/.conky/cal.sh}

# the next line is configurable
tmp="/dev/shm/conky.cal.sh" # choose a temporary file, preferably in a tmpfs
# as are the lines 24 to 38
# and nothing else

day=$(date +%-d)

newer=0
if [ ! -f $tmp ]; then
  newer=1
elif [ $day -gt $(date -r $tmp +%-d) ]; then
  newer=1
fi

if [ $newer -eq 1 ]; then
# the next few lines are configurable
  cal="cal" # add -s xor -m as desired, -j too

  align='${alignc}' # ${alignc}, ${alignr} or can be left empty (left alignment)

  # all colors below accept any one of:
  # conky predefined color: ${colorN} N is any of 0 to 9
  # conky color definition: ${color COLOR} COLOR can be a name or a hexcode
  #   formated as #xxxxxx
  # left empty: conky will use it's default color
  h_color='${color blue}' # week names header color
  d_color='${color red}' # today's color
  m_color='${color green}' # days of this month color
  pn_color='${color white}' # days of the previous and next months color
# and nothing else

  month=$(date +%-m)
  year=$(date +%-Y)

  if [ $month -eq 1 ]; then
    p_month=12
    p_year=$(($year - 1))
  else
    p_month=$(($month - 1))
    p_year=$year
  fi
  if [ $month -eq 12 ]; then
    n_month=1
    n_year=$(($year + 1))
  else
    n_month=$(($month + 1))
    n_year=$year
  fi

    cal $p_month $p_year |
    awk '
      $1 ~ /^[a-zA-Z]{2}$/ { header = $0; }
      {
        if (NF > 0) {
          last = this;
          this = $0;
          num = NF;
        }
      }
      END {
        print "'$align'""'"${h_color}"'"header"'"${pn_color}"'";
        if (num < 7) {
          print "'$align'"last;
          printf "'$align'%s'"${m_color}"'", this;
        } else {
          print "'$align'"this"'"${m_color}"'";
        }
      }
      ' > $tmp
    cal $month $year |
      awk '
        $1 >= 1 && $1 <= 31 {
          for (i = 0; i < NF; i++)
            if (match ($i, /^'"$day"'$/))
              sub(/'"$day"'/, "'"${d_color}&${m_color}"'");
          sub(/ {3,}/, "  ");
	  if (NF < 7)
            if ($1 > 15)
              printf "'$align'%s", $0;
            else
              print $0;
          else
            print "'$align'"$0;
        }
      ' >> $tmp
    cal $n_month $n_year |
      awk '
      	$1 == 1 {
       	  if (NF == 7)
            print "'"$align${pn_color}"'"$0"${color}";
          else {
            sub(/ {3,}/, "  ");
            print "'"${pn_color}"'"$0;
          }
        }
        $1 > 1 && $1 < 8 {
          print "'$align'"$0"${color}"
        }
      ' >> $tmp
fi

cat $tmp
