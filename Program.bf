using System;
using static raylib_beef.Raylib;
using raylib_beef.Types;
using raylib_beef.Enums;

namespace BondProject
{
	class Program
	{
		public enum GameState
		{
			MGM_SCREEN,
			GUNBARREL_SCREEN
		}

		class GunbarrelDot
		{
			public Vector2 *Position { get; set;}
			public float Timer { get; set; }
			public bool Active { get; set; }
			
			public this(Vector2 position, float timer, bool active)
			{
				Position = new Vector2(position.x, position.y);
				Timer = timer;
				Active = active;
			}
		}

		static float Vector2Distance(Vector2 a, Vector2 b)
		{
			return Math.Sqrt((a.x - b.x)*(a.x - b.x) + (a.y - b.y)*(a.y - b.y));
		}

		public static void UpdateGunbarrel(ref GunbarrelDot dotStart, ref GunbarrelDot nextDot, GunbarrelDot[] dots,
			ref int dotCounter, ref float circTimer, ref float dotGrowthTimer, float dotGrowthTimerMax, float dotSpeed, ref bool dotStopped,
			float dotTimeout, int maxDots, float dt)
		{
			if (dotStart.Position.x < dots[maxDots - 1].Position.x && !dotStopped)
			{
				dotStart.Position.x += dt * dotSpeed;
				if (Vector2Distance(*nextDot.Position, *dotStart.Position) < 3.0f && !nextDot.Active)
				{
					dots[dotCounter].Active = true;
					if (dotCounter < maxDots - 1)
					{
						dotCounter += 1;
						nextDot = dots[dotCounter];
					}
				}

				for (int i = 0; i < maxDots; i++)
				{
					if (dots[i].Active)
					{
						dots[i].Timer += dt;
						if (dots[i].Timer >= dotTimeout)
						{
							dots[i].Active = false;
						}
					}
				}

			}
			else
			{
				dotStopped = true;
			}

			if (dotStopped)
			{
				circTimer += dt;
				if (dotGrowthTimer < dotGrowthTimerMax) {
					dotGrowthTimer += dt;
				}
			}
		}

		public static void UpdateMGMScreen()
		{

		}

		public static void DrawMGMScreen()
		{

		}

		public static void DrawTextureCentered(Texture2D texture, float x, float y, float rot, float scale, Color color)
		{
			DrawTextureEx(texture, Vector2(x - texture.width/2.0f, y - texture.height/2.0f), rot, scale, color);
		}

		public static int Main()
		{
			int32 screenWidth = 1280;
			int32 screenHeight = 720;
			float gameTimer = 0.0f;
			InitWindow(screenWidth, screenHeight, "Moonraker");
			SetTargetFPS(60);

			int maxDots = 6;
			GunbarrelDot[] dots = new GunbarrelDot[maxDots];
			for (int i = 0; i < maxDots; i++)
			{
				dots[i] = new GunbarrelDot(Vector2(i*(screenWidth - 100.0f)/maxDots, 300.0f), 0.0f, false);
			}

			int dotCounter = 0;
			GunbarrelDot dotStart = dots[dotCounter];
			GunbarrelDot nextDot = dots[dotCounter];
			float dotTimeout = 0.4f;
			float dotSpeed = 350.0f;
			float dotRad = 40.0f;

			bool dotStopped = false;
			int dotGrowthCounter = 0;
			float dotGrowthTimerMax = 0.5f;
			float dotGrowthTimer = 0.0f;


			GameState gGameState = GameState.GUNBARREL_SCREEN;
			Texture2D gunbarrelTexture = LoadTexture("gunbarrel.png");
			Texture2D rogerTexture = LoadTexture("roger1.png");

			Shader gbShader = LoadShader("base.vs", "gunbarrel.fs");
			Shader slShader = LoadShader("base.vs", "spotlight.fs"); // spotlight shader
			int32 gbTexLoc = GetShaderLocation(gbShader, "tex");
			int32 slTexLoc = GetShaderLocation(slShader, "tex");
			SetShaderValueTexture(gbShader, gbTexLoc, gunbarrelTexture);
			SetShaderValueTexture(slShader, slTexLoc, rogerTexture);

			int32 gbTimerLoc = GetShaderLocation(gbShader, "timer");
			int32 gbCircLoc = GetShaderLocation(gbShader, "circCent");

			int32 slTimerLoc = GetShaderLocation(slShader, "timer");
			int32 slCircLoc = GetShaderLocation(slShader, "circCent");


			float circTimer = 0.0f;

			float spotlightTimer = 100.0f;

			Vector2 circLoc = *dots[maxDots - 1].Position;
			SetShaderValue(gbShader, gbCircLoc, (void*)&circLoc, ShaderUniformDataType.SHADER_UNIFORM_VEC2);
			SetShaderValue(gbShader, gbTimerLoc, (void*)&circTimer, ShaderUniformDataType.SHADER_UNIFORM_FLOAT);
			SetShaderValue(slShader, slCircLoc, (void*)&circLoc, ShaderUniformDataType.SHADER_UNIFORM_VEC2);

			while (!WindowShouldClose())
			{
				Update:
				{
					float dt = GetFrameTime();

					gameTimer += dt;

					switch (gGameState)
					{
					case (GameState.MGM_SCREEN):
						UpdateMGMScreen();
						break;
					case (GameState.GUNBARREL_SCREEN):
						UpdateGunbarrel(ref dotStart, ref nextDot, dots, ref dotCounter, ref circTimer, ref dotGrowthTimer, dotGrowthTimerMax, dotSpeed, ref dotStopped, dotTimeout, maxDots, dt);
						break;
					default:
						UpdateMGMScreen();
						break;
					}


				}

				Draw:
				{
					BeginDrawing();
					ClearBackground(.(0, 0, 0, 255));
					switch (gGameState)
					{
					case (GameState.MGM_SCREEN):
						DrawMGMScreen();
						break;
					case (GameState.GUNBARREL_SCREEN):
						{
							// todo: move all this somewhere clean
							for (var dot in dots)
							{
								if (dot.Active)
 								{
									 DrawCircle((int32)dot.Position.x, (int32)dot.Position.y, dotRad, Color.WHITE);
								}

							}

							if (dotStopped)
							{
								BeginShaderMode(gbShader);
								SetShaderValue(gbShader, gbTimerLoc, (void*)&circTimer, ShaderUniformDataType.SHADER_UNIFORM_FLOAT);
								DrawTextureEx(gunbarrelTexture, Vector2(-1800.0f + dotStart.Position.x, 0.0f), 0.0f, 10.0f, Color.WHITE);
								EndShaderMode();
								// rather than a straight circle, what we actually want here is to draw
								// the Roger/Sean/Daniel/Tim/George/Pierce sprite with a circle shader on it. 
								DrawCircle((int32)dotStart.Position.x, (int32)dotStart.Position.y, dotRad + dotGrowthTimer*200.0f, Color.WHITE);
								
								
								BeginShaderMode(slShader);
								//float spotlightRad = dotRad + dotGrowthTimer*200.0f;
								float spotlightRad = (dotRad + dotGrowthTimer*200.0f)/140.0f;
								SetShaderValue(slShader, slTimerLoc, (void*)&spotlightRad, ShaderUniformDataType.SHADER_UNIFORM_FLOAT);
								//DrawTextureEx(rogerTexture, Vector2(50.0f, 50.0f), 0.0f, 10.0f, Color.WHITE);
								DrawTextureCentered(rogerTexture, dotStart.Position.x - 10.0f, dotStart.Position.y - 50.0f, 0.0f, 2.0f, Color.WHITE);
								EndShaderMode();
							}
							else
							{
								DrawCircle((int32)dotStart.Position.x, (int32)dotStart.Position.y, dotRad, Color.WHITE);
							}
						}
						break;
					default:
						UpdateMGMScreen();
						break;
					}
					EndDrawing();

				}
				
			}

			for (var thing in dots)
			{
				delete thing.Position;
				delete thing;
			}
			delete dots;
			return 0;
		}
	}
}
