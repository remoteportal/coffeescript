// coffeescript.js: Generated by CoffeeScript GITLAB/lib 2.3.0
var Peter, UT, ut;

Peter = require('./peter');

UT = require('./ut');

Peter.s_ut(0);

ut = new UT(process.argv, true, {}, (eventName) => {
  if (eventName.startsWith("exit-")) {
    return process.exit(0);
  }
});

ut.run();
