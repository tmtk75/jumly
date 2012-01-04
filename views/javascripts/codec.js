// This is based on sample code on followings articles.
// http://www.atmarkit.co.jp/fcoding/articles/algorithm/08/algorithm08a.html
// http://www.atmarkit.co.jp/fcoding/articles/algorithm/09/algorithm09a.html
// I don't know the license.
(function() {
function BitArray() {
  this.length = 0;
}
BitArray.prototype.get = function(begin, len) {
  if(this.length < (begin + len)) {
    return null;
  }
  var value = 0;
  for(var i = 0; i < len; i++) {
    value = value << 1;
    value += (this[begin + i] ? 1 : 0);
  }
  return value;
}
BitArray.prototype.add = function(value, len) {
  for(var i = 0; i < len; i++) {
    var v = value >>> (len - i - 1);
    var bit = ((v & 1) == 1);
    this[this.length] = bit;
    this.length++;
  }
}
function HuffmanTree(data, compressed) {
  if(compressed) {
    this.setCompressedData(data);
  } else {
    this.data = data;
    var charcounter = this.getCharCounter();
    this.setHeaderData(charcounter);
    this.setTreeData();
  }
}
HuffmanTree.prototype.getCharCounter = function() {
  var charcounter = new Array();
  for(var i = 0; i < this.data.length; i++) {
    var chnum = this.data.charCodeAt(i);
    if(charcounter[chnum] == undefined) {
      charcounter[chnum] = 0;
    }
    charcounter[chnum]++;
  }
  return charcounter;
}
HuffmanTree.prototype.setHeaderData = function(charcounter) {
  this.headerdata = new Array();
  for(var chnum = 0; chnum < charcounter.length; chnum++) {
    if(charcounter[chnum] === undefined) {
      continue;
    }
    var chcountdata = {
      count : charcounter[chnum],
      chnum : chnum
    };
    this.headerdata.push(chcountdata);
  }
}
HuffmanTree.prototype.setTreeData = function() {
  var sortdata = this.headerdata.slice(0);  // To clone
  sortdata.sort(function(a, b) {return b.count - a.count;});
  var insertCount = function(that, value) {
    for(var i = that.length - 1; 0 <= i; i--) {
      if(value.count < that[i].count)
        break;
      that[i + 1] = that[i];
    }
    that[i + 1] = value;
  }
  while(true) {
    var min1 = sortdata.pop();
    var min2 = sortdata.pop();
    if(min2 === undefined) {
      this.treedata = min1;
      break;
    }
    var count = min1.count + min2.count;
    var node = {
      count : count,
      left : min1,
      right : min2
    };
    insertCount(sortdata, node);
  }
}
HuffmanTree.prototype.getEncodeData = function() {
  var endata = new BitArray();
  endata.add(this.headerdata.length, 8);
  for(var i = 0; i < this.headerdata.length; i++) {
    var chcountdata = this.headerdata[i];
    endata.add(chcountdata.chnum, 16);
    endata.add(chcountdata.count, 16);
  }
  var n2chr = new Array();
  function mapn2chr(node, code, len) {
    if(node.chnum !== undefined) {
      n2chr[node.chnum] = {
        code : code,
        len : len
      };
    } else {
      mapn2chr(node.left, (code << 1) + 1, len + 1);
      mapn2chr(node.right, (code << 1), len + 1);
    }
  }
  mapn2chr(this.treedata, 0, 0);
  for(var i = 0; i < this.data.length; i++) {
    var huffmancode = n2chr[this.data.charCodeAt(i)];
    endata.add(huffmancode.code, huffmancode.len);
  }
  return endata;
}
HuffmanTree.prototype.setCompressedData = function(data) {
  var len = data.get(0, 8);
  var charcounter = new Array();
  for(var i = 0; i < len; i++) {
    var chnum = data.get(8 + (i * 32), 16);
    var count = data.get(24 + (i * 32), 16);
    charcounter[chnum] = count;
  }
  this.setHeaderData(charcounter);
  this.setTreeData();
  var dedata = new Array();
  function rec(argnode, i) {
    var node = argnode;
    if(node.chnum !== undefined) {
      var ch = String.fromCharCode(node.chnum);
      dedata.push(ch);
      return i;
    }
    var bit = data.get(i, 1);
    if(bit === null) {
      return;
    }
    if(bit == 0) {
      return rec(node.right, i + 1);
    } else {
      return rec(node.left, i + 1);
    }
  }
  var index = 8 + (len * 32);
  while(index < data.length) {
    index = rec(this.treedata, index);
  }
  this.data = dedata;
}

var Huffman = {}
Huffman.encode = function(data) {
  var huffmanTree = new HuffmanTree(data, false);
  var endata = huffmanTree.getEncodeData();
  return endata;
}
Huffman.decode = function(data) {
  var huffmanTree = new HuffmanTree(data, true);
  return huffmanTree.data;
}
String.prototype.toArray = function() {
  var ary = new Array(this.length);
  for(var i = 0; i < this.length; i++) {
    ary[i] = this.charAt(i);
  }
  return ary;
}
// Block-sorting, Burrows-Wheeler Transformation
var BWT = {}
BWT.encode = function(data) {
  var endata = new Array();
  var BWTBLOCKLEN = data.length;
  var srcdata = data;
  if((data.length % BWTBLOCKLEN) != 0) {
    for(var i = 0; i < (BWTBLOCKLEN - (data.length % BWTBLOCKLEN)); i++) {
      srcdata = srcdata + '0';
    }
  }
  var blocknum = srcdata.length / BWTBLOCKLEN;
  endata.push(String.fromCharCode(data.length))
  endata.push(String.fromCharCode(blocknum))
  for(var i = 0; i < blocknum; i++) {
    var line = srcdata.slice(i * BWTBLOCKLEN, (i + 1) * BWTBLOCKLEN).toArray();
    var block = new Array();
    for(var j = 0; j < BWTBLOCKLEN; j++) {
      block.push(line.join("") + String.fromCharCode(j));
      var value = line.shift(i);
      line.push(value);
    }
    block.sort();
    var encodeline = new Array(BWTBLOCKLEN + 1);
    for(var j = 0; j < BWTBLOCKLEN; j++) {
      var n = block[j].charAt(BWTBLOCKLEN);
      if(n == String.fromCharCode(0)) {
        encodeline[BWTBLOCKLEN] = String.fromCharCode(j);
      }
      encodeline[j] = block[j].charAt(BWTBLOCKLEN - 1);
    }
    endata = endata.concat(encodeline);
  }
  return endata;
}
BWT.decode = function(data) {
  var dedata = new Array();
  var len = data.shift().charCodeAt(0);
  var blocknum = data.shift().charCodeAt(0);
  var BWTBLOCKLEN = len;
  for(var i = 0; i < blocknum; i++) {
    var ary = data.slice(i * (BWTBLOCKLEN + 1), (i + 1) * (BWTBLOCKLEN + 1));
    var lineno = ary.pop().charCodeAt(0);
    var firstcol = new Array(ary.length);
    for(var j = 0; j < ary.length; j++) {
      firstcol[j] = {
        ch : ary[j],
        index : j
      };
    }
    firstcol.sort(function(a, b) {
      if(a.ch != b.ch) {
        return a.ch.charCodeAt(0) - b.ch.charCodeAt(0);
      } else {
        return a.index - b.index;
      }
    });
    line = new Array(ary.length);
    for(var j = 0; j < ary.length; j++) {
      var f = firstcol[lineno];
      line[j] = f.ch;
      lineno = f.index;
    }
    dedata = dedata.concat(line);
  }
  return dedata.slice(0, len);
}
var remove = function(that, index) {
  for(var j = index; j < that.length - 1; j++) {
    that[j] = that[j + 1];
  }
  that.pop();
}
// Move To Front
var MTF = {}
MTF.encode = function(data) {
  var endata = new Array();
  var chrseq = new Array();
  for(var i = 0; i < data.length; i++) {
    var ch = data.charAt(i);
    var index = chrseq.indexOf(ch);
    if(index == -1) {
      chrseq.push(ch);
    }
  }
  endata[0] = String.fromCharCode(chrseq.length);
  endata = endata.concat(chrseq);
  for(var i = 0; i < data.length; i++) {
    var ch = data.charAt(i);
    var index = chrseq.indexOf(ch);
    if(index == -1) { alert(chrseq);
    }
    remove(chrseq, index);
    chrseq.unshift(ch);
    endata.push(String.fromCharCode(index));
  }
  return endata;
}
MTF.decode = function(data) {
  var dedata = new Array();
  var len = data[0].charCodeAt(0);
  var chrseq = data.slice(1, len + 1);
  for(var i = len + 1; i < data.length; i++) {
    var index = data[i].charCodeAt(0);
    var ch = chrseq[index];
    remove(chrseq, index);
    chrseq.unshift(ch);
    dedata.push(ch);
  }
  return dedata;
}
window.Codec = {}
Codec.BWTMTFHuffman = {
  encode: function(data) {
    var encodebwtdata = BWT.encode(data);
    var encodemtfdata = MTF.encode(encodebwtdata.join(""));
    return Huffman.encode(encodemtfdata.join(""));
  },
  decode: function(encodehuffmandata) {
    var decodehuffmandata = Huffman.decode(encodehuffmandata);
    var decodemtfdata = MTF.decode(decodehuffmandata);
    return BWT.decode(decodemtfdata);
  }
}
})();