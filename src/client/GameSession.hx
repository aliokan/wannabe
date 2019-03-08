package client;

class GameSession implements Model {
  @:forward
  @:constant private var game:Game;
  @:constant var self:Player;
  @:computed var isMyTurn:Bool = switch nextUnit {
    case None: false;
    case Some(u): u.owner == self;
  }
}