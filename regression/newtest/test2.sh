#!/bin/sh
TEST_CLASSES="Hello Casting Loops TestStringBuffer TestThreadState" # Collatz ArrayOps
OUT_FILE=out
REPORT_FILE=report.html

export CLASSPATH=.
export PATH=.:../../bin:$PATH



cat > $REPORT_FILE <<EOF
<html>

<head>
<style>
div{
margin: 3px;
border-style:solid;
border-left-width:5pt;
border-bottom-width:2pt;
border-top-width:0pt;
border-right-width:0pt;
padding: 2px;
padding-left: 15pt;
font-family: Sans-Serif;
}
div.pass{
background-color:#daffb3;
border-color: #65c400;
}

div.fail{
background-color:#feeac3;
border-color: #c20000;
}

div.source{
background-color:#333;
border-color: #000;
font-family: monospace;
color: #eee;
}
</style>
</head>
<body>

EOF



# allow core dump
# If core dumps are not processed proably take a look at /proc/sys/kernel/core_pattern
ulimit -c unlimited 



for i in $TEST_CLASSES
do
  echo -n $i "         "
  lejosc $i.java  > $OUT_FILE.lejosc 2>&1
  emu-lejos $i -o $i.tvm > $OUT_FILE.tvm 2>&1
  emu-lejosrun -v $i.tvm >> $OUT_FILE.tvm 2>&1
  java -cp ./jvm/:. $i  > $OUT_FILE.jvm 2>&1
  
  if diff $OUT_FILE.tvm $OUT_FILE.jvm >/dev/null 2>&1
  then
    echo "[ OK ]"
    echo "<div class="pass"> Test1: Pass </div>" >> $REPORT_FILE
  else
    cat >> $REPORT_FILE <<EOF
    <div class="fail"> $i: Fail

<br/>
Source:
<div class="source">
$(code2html -ljava -n $i.java)
</div>


Compiler output:
<div class="source">
<pre>
$(cat $OUT_FILE.lejosc)
</pre>
</div>

JVM output:
<div class="source">
<pre>
$(cat $OUT_FILE.jvm)
</pre>
</div>
TVM output:
<div class="source">
<pre>
$(cat $OUT_FILE.tvm)
</pre>
</div>
EOF


    if [ -f core ]
    then
      echo 'coredump:<div class="source"><pre>' >> $REPORT_FILE
      gdb --quiet --command=backtrace.gdb --batch ../../bin/emu-lejosrun core >> $REPORT_FILE  2>&1
      rm core
      echo '</pre></div>' >> $REPORT_FILE
    fi

cat <<EOF >> $REPORT_FILE
</div>
</div>
EOF

    echo "[Fail]"
  fi
  
done


cat >> $REPORT_FILE <<EOF

</div>
</body>
</html>

EOF

