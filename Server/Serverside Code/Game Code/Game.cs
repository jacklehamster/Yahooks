using System;
using System.Collections.Generic;
using System.Text;
using System.Collections;
using PlayerIO.GameLibrary;
using System.Drawing;

namespace Wonderland
{
	public class Player : BasePlayer {
	}

    [RoomType("Wonderland")]
	public class GameCode : Game<Player> {

        private uint tick = 0;

		public override void GameStarted() {
            AddTimer(delegate
            {
                Broadcast("tick",tick++);
            }, 100);

        }

        public override void UserJoined(Player player)
        {
            base.UserJoined(player);
            Broadcast("joined",this.PlayerCount);
            BroadcastLeaderboard(player);
/*            PlayerIO.BigDB.LoadRange("Chat", "date", null, null, null, 200,
                delegate (DatabaseObject[] array) {
                    if (array.Length>0)
                    {
                        Message message = Message.Create("send");
                        message.Add(true);
                        foreach (DatabaseObject data in array)
                        {
                            String objectId = data.GetString("objectId");
                            String action = data.GetString("action");
                            byte[] bytes = data.GetBytes("params");
                            message.Add(objectId);
                            message.Add(action);
                            message.Add(bytes);
                        }
                        player.Send(message);
                        if(array.Length>100)
                            PlayerIO.BigDB.DeleteRange("Chat", "date", null, array[array.Length / 2].GetDateTime("date"), null, null);
                    }
                });*/
        }

        private void BroadcastLeaderboard(Player player=null,int rankFor=0,Action<int> rankCallback=null) 
        {
            PlayerIO.BigDB.LoadRange("Leaderboard", "score", null, null, null, rankCallback != null ? 1000 : 10,
                delegate(DatabaseObject[] array)
                {
                    if (array.Length > 0)
                    {
                        Message message = Message.Create("leaderboard");
                        int maxcount = 10, rank = 1;
                        foreach (DatabaseObject data in array)
                        {
                            String name = data.GetString("name");
                            int score = data.GetInt("score");
                            if (message.Count < maxcount * 2) {
                                message.Add(name);
                                message.Add(score);
                            }
                            if (rankCallback != null && rankFor < score)
                            {
                                rank++;
                            }
                        }
                        if (rankCallback!=null)
                        {
                            rankCallback(rank);
                        }
                        if (player != null)
                            player.Send(message);
                        else
                            Broadcast(message);
                    }
                });
        }

        public override void UserLeft(Player player)
        {
            base.UserLeft(player);
            Broadcast("playerLeft", player.ConnectUserId, this.PlayerCount);
        }

        private void handleScore(Player player,Message message)
        {
            DatabaseObject obj = new DatabaseObject();
            String name = message.GetString(0);
            int score = message.GetInteger(1);
            PlayerIO.BigDB.LoadOrCreate("Leaderboard", name,
                delegate(DatabaseObject databaseObject)
                {
                    int bestScore;
                    Boolean updateScore = !databaseObject.Contains("score") || databaseObject.GetInt("score") < score;
                    if (updateScore)
                    {
                        bestScore = score;
                        databaseObject.Set("name", name);
                        if (updateScore)
                        {
                            databaseObject.Set("score", score);
                        }
                        databaseObject.Save(
                            delegate
                            {
                                BroadcastLeaderboard(null, bestScore,
                                    delegate(int rank)
                                    {
                                        player.Send("rank", rank);
                                    });
                            });
                    }
                    else
                    {
                        bestScore = databaseObject.GetInt("score");
                        BroadcastLeaderboard(null, bestScore,
                            delegate(int rank)
                            {
                                player.Send("rank", rank);
                            });
                    }
                });
        }

        private void handleMessage(Message message) {

            Broadcast(message);

            Boolean persist = message.GetBoolean(0);
            if (persist)
            {
                String objectId = message.GetString(1);
                String action = message.GetString(2);
                byte[] bytes = message.GetByteArray(3);
                DatabaseObject obj = new DatabaseObject();
                obj.Set("objectId", objectId);
                obj.Set("action", action);
                obj.Set("params", bytes);
                obj.Set("date", DateTime.Now);
                PlayerIO.BigDB.CreateObject("Chat", null, obj, null);
            }
        }

		// This method is called when a player sends a message into the server code
		public override void GotMessage(Player player, Message message) {
            base.GotMessage(player, message);
			switch(message.Type) {
                case "score":
                    handleScore(player,message);
                    break;
                case "send":
                    handleMessage(message);
                    break;
                default:
                    Console.WriteLine("Received message:",message.Type);
                    break;
			}
		}
	}
}
