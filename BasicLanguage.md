

Experimental machine's specification:
  * Hardware: Xeon E5530 2.4GHz CPU 8 cores, 24GB MEM
  * Software: Linux 2.6.26, gcc 4.3.2, chapel 1.3.0
(Using develop Chapel, up to rev19213 9/28/2011, presents similar results.)

# Arithmetic and Vector Manipulation #
Program [basic.c](http://code.google.com/p/mdoch/source/browse/eval/basic.c) and [basic.chpl](http://code.google.com/p/mdoch/source/browse/eval/basic.chpl) compare the performance of basic arithmetics: assignment, addition, subtraction, multiplication, and division, for both float point types and vector array. These two programs are compiled as
```
$ gcc -o basic_c basic.c -O3 -lm
$ chpl -o basic_chpl basic.chpl --fast
```

All comparisons are the average of 5 identical runs. The number of operations is 1 million.
```
$ for i in `seq 1 5`; do eval/basic_c 1000000; done 
$ for i in `seq 1 5`; do eval/basic_chpl --arrSize=1000000; done
```

![https://docs.google.com/spreadsheet/oimg?key=0AsQUQWzou-B5dG94MDl1dlJiMTc1WkllZ3N1Ujh1WUE&oid=4&zx=xtnd9wouuu7y&nonsense=vector.png](https://docs.google.com/spreadsheet/oimg?key=0AsQUQWzou-B5dG94MDl1dlJiMTc1WkllZ3N1Ujh1WUE&oid=4&zx=xtnd9wouuu7y&nonsense=vector.png)

Vector and its manipulations play an important role in MD simulation, which also lead to non-trivial performance impact by using different structure data types. Chapel provides two kinds of light-weight data types that can be used to implement vector: tuple and record.

For each kind of operation, both 1D-vector and 2D-vector are used. 2D-vector is the vector of 1D-vector, i.e.,
```
// 1D-Type
type Tuple = (real, real, real);
record Record {var x, y, z: real;}
// 2D-Type
type Tuple2D = (Tuple, Tuple, Tuple);
record Record2D {var x, y, z: Record;}
```
which is used to measure the packing/unpacking overhead of vectors.

![https://docs.google.com/spreadsheet/oimg?key=0AsQUQWzou-B5dG94MDl1dlJiMTc1WkllZ3N1Ujh1WUE&oid=5&zx=umw5xzw8ju94&nonsense=vector.png](https://docs.google.com/spreadsheet/oimg?key=0AsQUQWzou-B5dG94MDl1dlJiMTc1WkllZ3N1Ujh1WUE&oid=5&zx=umw5xzw8ju94&nonsense=vector.png)

![https://docs.google.com/spreadsheet/oimg?key=0AsQUQWzou-B5dG94MDl1dlJiMTc1WkllZ3N1Ujh1WUE&oid=6&zx=tt9lsxloei6e&nonsense=vector2d.png](https://docs.google.com/spreadsheet/oimg?key=0AsQUQWzou-B5dG94MDl1dlJiMTc1WkllZ3N1Ujh1WUE&oid=6&zx=tt9lsxloei6e&nonsense=vector2d.png)

For 1D-vector, the performance by using `tuple` and `record` are nearly equal. For 2D-vector, using `record` has a 1.5x speedup then using `tuple`.

Two simple MD programs, [src/allpairs2d.chpl](http://code.google.com/p/mdoch/source/browse/src/allpairs2d.chpl) and [eval/allpairs2d.chpl](http://code.google.com/p/mdoch/source/browse/eval/allpairs2d.chpl), are identical except their vector are implemented by `record` and `tuple`, respectively. We compare their performance by specify with different simulation steps, as
```
$ chpl -o allpairs2d allpairs2d.chpl --fast // No $CHPL_COMM set
# Run 5 times for each N, and measure the average
$ time ./allpairs2d --maxThreadsPerLocale=1 --stepAvg=1000 --stepLimit=N # N=1000,2000,...,10000
```

![https://docs.google.com/spreadsheet/oimg?key=0AsQUQWzou-B5dG94MDl1dlJiMTc1WkllZ3N1Ujh1WUE&oid=2&zx=lphizgbweu3a&nonsense=allpairs2d.png](https://docs.google.com/spreadsheet/oimg?key=0AsQUQWzou-B5dG94MDl1dlJiMTc1WkllZ3N1Ujh1WUE&oid=2&zx=lphizgbweu3a&nonsense=allpairs2d.png)

In `allpairs2d`, using `record` is about 1.4x faster than using `tuple`. The performance of direct C code [c/allpairs2d.c](http://code.google.com/p/mdoch/source/browse/c/allpairs2d.c) (use array of `struct` as vector) is also shown.

### Why using `tuple` is slow? ###
By Chapel code generation command,
```
$ chpl -o basic basic.chpl --codegen --savec basic_c --fast
```
the actual target C code is shown as
```
type nstTuple= (Tuple, Tuple, Tuple);
record nstRecord {var x, y, z: Record;}
var resNstTup: nstTuple;
var resNstRec: nstRecord;
```

which is accordingly converted to

```
Record _construct_Record(_real64 x, _real64 y, _real64 z, Record* const meme, 
  int32_t _ln, chpl_string _fn) {
  Record this8;
  this8 = (*meme);
  this8.x = x;
  this8.y = y;
  this8.z = z;
  return this8;
}

Record chpl___ASSIGN_11(Record* const _arg1, Record* const _arg2) {
  _real64 _ret;
  _real64 _ret2;
  _real64 _ret3;
  _ret = ((*_arg2).x);
  (*_arg1).x = _ret;
  _ret2 = ((*_arg2).y);
  (*_arg1).y = _ret2;
  _ret3 = ((*_arg2).z);
  (*_arg1).z = _ret3;
  return (*_arg1);
}

nstRecord _construct_nstRecord(Record* const x, Record* const y, Record* const z, 
  nstRecord* const meme, int32_t _ln, chpl_string _fn) {
  nstRecord this8;
  this8 = (*meme);
  this8.x = (*x);
  this8.y = (*y);
  this8.z = (*z);
  return this8;
}

(resNstTup[0])[0] = (T50)[0];
resNstRec.x = chpl___ASSIGN_11(&(T55), &(resRec));
```

# Rectangular vs. Irregular Domains #

Chapel supports rectangular domain and irregular domain, which are used to create arbitrary shapes of memory. Irregular domain is like _dictionary_ type, and uses objects as the index.

[array.chpl](http://code.google.com/p/mdoch/source/browse/eval/array.chpl) evaluates the performance of array reference by using different types of domains, and following figures show the results.

### 1D Domain ###
![https://docs.google.com/spreadsheet/oimg?key=0AsQUQWzou-B5dG94MDl1dlJiMTc1WkllZ3N1Ujh1WUE&oid=13&zx=nohbemhj0tzr&nonsense=1darray.png](https://docs.google.com/spreadsheet/oimg?key=0AsQUQWzou-B5dG94MDl1dlJiMTc1WkllZ3N1Ujh1WUE&oid=13&zx=nohbemhj0tzr&nonsense=1darray.png)

### 2D Domain ###
![https://docs.google.com/spreadsheet/oimg?key=0AsQUQWzou-B5dG94MDl1dlJiMTc1WkllZ3N1Ujh1WUE&oid=14&zx=mfhdbyazauik&nonsense=2darray.png](https://docs.google.com/spreadsheet/oimg?key=0AsQUQWzou-B5dG94MDl1dlJiMTc1WkllZ3N1Ujh1WUE&oid=14&zx=mfhdbyazauik&nonsense=2darray.png)

### 3D Domain ###
![https://docs.google.com/spreadsheet/oimg?key=0AsQUQWzou-B5dG94MDl1dlJiMTc1WkllZ3N1Ujh1WUE&oid=15&zx=s1fe6d7v0a0g&nonsense=3darray.png](https://docs.google.com/spreadsheet/oimg?key=0AsQUQWzou-B5dG94MDl1dlJiMTc1WkllZ3N1Ujh1WUE&oid=15&zx=s1fe6d7v0a0g&nonsense=3darray.png)

# Nested Loops #
[loop.chpl](http://code.google.com/p/mdoch/source/browse/eval/loop.chpl)
measures the performance of nested loops. Basically, there are two varients of
loop construction: `for` loop or `while` loop.
Following figure shows that using nested `for` loop has an extra overhead,
where "for-for" stands for _nested style_ loops,
```
for i in [1..I] {
  for j in [1..J] {
    ...
  }
}
```
and "for,for" stands for _multidimentional style_ loops,
```
for (i, j) in [1..I, 1..J] { 
  ...
}
```

![https://docs.google.com/spreadsheet/oimg?key=0AsQUQWzou-B5dG94MDl1dlJiMTc1WkllZ3N1Ujh1WUE&oid=16&zx=bssp4g6h4c7d&nonsense=nested_array.png](https://docs.google.com/spreadsheet/oimg?key=0AsQUQWzou-B5dG94MDl1dlJiMTc1WkllZ3N1Ujh1WUE&oid=16&zx=bssp4g6h4c7d&nonsense=nested_array.png)

By investigating translated C code,
```
$ chpl -o loop loop.chpl --codegen --savec loop_c --fast
```
it can be found that, in Chapel, a `for` loop consists of a range
construction procedure and a corresponding `while` loop.
```
for i in [1..I] do ...

// is translated to

...
chpl__buildDomainExpr2(&loop_domain, ...);
while (loop_domain) {
  ...
}
chpl__autoDestroy2(loop_variable, ...);
```

Therefore, in a nested `for` loop, the domain construction/destruction
procedures of _inner loop_ are also repeated, which introduces more overhead.
For example,
```
// Chapel code
for i in [1..I] {   // outer loop
  for j in [1..J] { // inner loop
    ...
  }
}

// Transalted C code
...
chpl__buildDomainExpr2(&outer_loop_domain, ...);
while (outer_loop_variable) { /* outer loop */
  chpl__buildDomainExpr2(&inner_loop_domain, ...);
  while (inner_loop_variable) { /* inner loop */
    ...
  }
  chpl__autoDestroy2(inner_loop_domain, ...);
}
chpl__autoDestroy2(outer_loop_domain, ...);
```

While a "for,for" style loop does not introduce this overhead, it cannot be
used to construct nested loops where inner loop depends on outer iterations,
such as,
```
// Inner loop depends on outer loop
for i in [1..I] do
  for j in [1..i-1] do ... // Using "while" instead 
```