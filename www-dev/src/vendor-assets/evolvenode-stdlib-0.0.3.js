window['evolvenode-stdlib'] = {};


/*
  @setImmediate
 */

(function() {
  var Collector, Condition, Iterator, Notifier, _setImmediate, asyncIf, deepCopy, delay, e, error, iterate, shallowCopy,
    slice = [].slice,
    bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  try {
    _setImmediate = setImmediate;
  } catch (error) {
    e = error;
    'pass';
  }

  if (!_setImmediate) {
    _setImmediate = function() {
      var args, fn;
      fn = arguments[0], args = 2 <= arguments.length ? slice.call(arguments, 1) : [];
      return window.setTimeout(function() {
        return fn.apply({}, args);
      }, 0);
    };
  }

  this.setImmediate = _setImmediate;


  /*
    @delay
   */

  delay = function(timeout, fn) {
    return setTimeout(fn, timeout);
  };

  this.delay = delay;


  /*
    @class Collector
    @purpose Asynchronous counter and data collector
   */

  Collector = (function() {
    function Collector(totalToCollect) {
      this.totalToCollect = totalToCollect;
      this.count = 0;
      this.collection = {};
    }

    Collector.prototype.collect = function(key, value) {
      var finallyFn;
      if (this.totalToCollect !== this.count) {
        this.collection[key] = value;
        this.count += 1;
      }
      if (this.totalToCollect === this.count) {
        if (this.finallyFn) {
          _setImmediate(this.finallyFn, this.collection);
        }
        return finallyFn = null;
      }
    };

    Collector.prototype["finally"] = function(finallyFn1) {
      this.finallyFn = finallyFn1;
      return this;
    };

    return Collector;

  })();

  this.Collector = Collector;


  /*
    @class Iterator
    @purpose Asynchronous iterator for a list with flow control.
   */

  Iterator = (function() {
    function Iterator(list1) {
      this.list = list1;
      this.next = bind(this.next, this);
      this.index = 0;
      this.hasIterationEnded = false;
      _setImmediate(this.next);
    }

    Iterator.prototype.forEach = function(forEachFn1) {
      this.forEachFn = forEachFn1;
      return this;
    };

    Iterator.prototype.next = function() {
      var cb, oldIndex;
      if (this.index === this.list.length) {
        this.hasIterationEnded = true;
        if (this.finalFn && this.hasIterationEnded) {
          cb = this.finalFn;
          this.finalFn = null;
          return cb();
        }
      } else {
        oldIndex = this.index;
        this.index++;
        return this.forEachFn(this.next, oldIndex, this.list[oldIndex]);
      }
    };

    Iterator.prototype["finally"] = function(finalFn) {
      var cb;
      this.finalFn = finalFn;
      if (this.finalFn && this.hasIterationEnded) {
        cb = this.finalFn;
        this.finalFn = null;
        cb();
      }
      return this;
    };

    return Iterator;

  })();

  this.Iterator = Iterator;


  /*
    @iterate
   */

  iterate = function(list, forEachFn) {
    var it;
    it = new Iterator(list);
    it.forEach(forEachFn);
    return it;
  };

  this.iterate = iterate;


  /*
    @class Condition
    @purpose Asynchronous condition
   */

  Condition = (function() {
    function Condition() {
      this._evalIfReady = bind(this._evalIfReady, this);
      this.truthyCbfn = null;
      this.falsyCbfn = null;
      this.isExpressionSet = false;
      this.isExecuted = false;
    }

    Condition.prototype.then = function(truthyCbfn) {
      this.truthyCbfn = truthyCbfn;
      return this;
    };

    Condition.prototype["else"] = function(falsyCbfn) {
      this.falsyCbfn = falsyCbfn;
      return this;
    };

    Condition.prototype["eval"] = function(fnOrExpression1) {
      this.fnOrExpression = fnOrExpression1;
      this.isExpressionSet = true;
      _setImmediate(this._evalIfReady);
      return this;
    };

    Condition.prototype["finally"] = function(finalCbfn) {
      this.finalCbfn = finalCbfn;
      _setImmediate(this._evalIfReady);
      return this;
    };

    Condition.prototype._evalIfReady = function() {
      if (this.isExpressionSet && !this.isExecuted) {
        this.isExecuted = true;
        if (typeof this.fnOrExpression === 'function') {
          this.fnOrExpression = this.fnOrExpression();
        }
        if (this.fnOrExpression) {
          if (this.truthyCbfn) {
            return this.truthyCbfn(this.finalCbfn);
          } else {
            return this.finalCbfn();
          }
        } else {
          if (this.falsyCbfn) {
            return this.falsyCbfn(this.finalCbfn);
          } else {
            return this.finalCbfn();
          }
        }
      }
    };

    return Condition;

  })();

  this.Condition = Condition;


  /*
    @asyncIf
   */

  asyncIf = function(fnOrExpression) {
    var con;
    con = new Condition;
    con["eval"](fnOrExpression);
    return con;
  };

  this.asyncIf = asyncIf;


  /*
    @class Notifier
    @purpose Lightweight and portable alternative to nodejs EventEmitters
   */

  Notifier = (function() {
    function Notifier() {
      this.subscriberFnList = [];
    }

    Notifier.prototype.notify = function() {
      var data;
      data = 1 <= arguments.length ? slice.call(arguments, 0) : [];
      _setImmediate((function(_this) {
        return function() {
          var fn, i, len, ref;
          ref = _this.subscriberFnList;
          for (i = 0, len = ref.length; i < len; i++) {
            fn = ref[i];
            fn.apply({}, data);
          }
          if (_this.finalCbfn) {
            return _setImmediate(_this.finalCbfn);
          }
        };
      })(this));
      return this;
    };

    Notifier.prototype["finally"] = function(finalCbfn) {
      this.finalCbfn = finalCbfn;
      return this;
    };

    Notifier.prototype.subscribe = function(fn) {
      return this.subscriberFnList.push(fn);
    };

    Notifier.prototype.unsubscribe = function(fn) {
      var index;
      if ((index = this.subscriberFnList.indexOf(fn)) > -1) {
        return this.subscriberFnList.splice(index, 1);
      }
    };

    return Notifier;

  })();

  this.Notifier = Notifier;


  /*
    @shallowCopy
   */

  shallowCopy = function(obj) {
    var flags, key, temp;
    if (obj === null || typeof obj !== "object") {
      return obj;
    }
    if (obj instanceof Date) {
      temp = new Date(obj.getTime());
      return temp;
    }
    if (obj instanceof RegExp) {
      flags = '';
      if (obj.global !== null) {
        flags += 'g';
      }
      if (obj.ignoreCase !== null) {
        flags += 'i';
      }
      if (obj.multiline !== null) {
        flags += 'm';
      }
      if (obj.sticky !== null) {
        flags += 'y';
      }
      return new RegExp(obj.source, flags);
    }
    temp = new obj.constructor();
    for (key in obj) {
      temp[key] = obj[key];
    }
    return temp;
  };

  this.shallowCopy = shallowCopy;


  /*
    @deepCopy
   */

  deepCopy = function(obj) {
    var flags, key, temp;
    if (obj === null || typeof obj !== "object") {
      return obj;
    }
    if (obj instanceof Date) {
      temp = new Date(obj.getTime());
      return temp;
    }
    if (obj instanceof RegExp) {
      flags = '';
      if (obj.global !== null) {
        flags += 'g';
      }
      if (obj.ignoreCase !== null) {
        flags += 'i';
      }
      if (obj.multiline !== null) {
        flags += 'm';
      }
      if (obj.sticky !== null) {
        flags += 'y';
      }
      return new RegExp(obj.source, flags);
    }
    temp = new obj.constructor();
    for (key in obj) {
      temp[key] = deepCopy(obj[key]);
    }
    return temp;
  };

  this.deepCopy = deepCopy;

}).call(window['evolvenode-stdlib']);

