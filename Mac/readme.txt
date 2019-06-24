源码位置：https://github.com/meyerd/n2n

常用命令
edge1 -a 10.10.0.15 -c n2n -k n2n -l n2n.lucktu.com:10082 -b
edge2 -a 10.10.0.15 -c n2n -k n2n -l n2n.lucktu.com:10086 -b
edges -a 10.10.0.15 -c n2n -k n2n -l n2n.lucktu.com:10088 -b

----------------------------以下自用--------------------------

edge1 -a 10.0.1.15 -c shckw -k 1OO82 -l n1.lucktu.com:10082 -b
edged -a 10.0.3.15 -c shckw -k 1OO86 -l n1.lucktu.com:10086 -brA
edged -a 10.0.4.15 -c shckw          -l n4.lucktu.com:10086 -brA
edge2 -a 10.0.7.15 -c shckw -k 1OO86 -l n1.lucktu.com:10086 -b
edges -a 10.0.9.15 -c shckw -k 1OO88 -l n1.lucktu.com:10088 -f -b