using System;
using static raylib_beef.Raylib;
using raylib_beef.Types;
using raylib_beef.Enums;

// dots should only disappear when new one is spawning

namespace BondProject
{
	class Program
	{
		public enum GameState
		{
			MGM_SCREEN,
			GUNBARREL_SCREEN,
			SKYDIVING_SCREEN,
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

		class SpriteSheet
		{
			public int32 CurrentFrame;
			public int32 TotalFrames;
			public float Timer;
			public float FrameTime;
			public float FrameWidth;
			public float FrameHeight;
			public Rectangle CurrentRect;
			

			public this(int32 currentFrame, int32 totalFrames, float timer, float frameTime, float frameWidth, float frameHeight)
			{
				CurrentFrame = currentFrame;
				TotalFrames = totalFrames;
				Timer = timer;
				FrameTime = frameTime;
				FrameWidth = frameWidth;
				FrameHeight = frameHeight;
				CurrentRect = Rectangle(0.0f, 0.0f, FrameWidth, FrameHeight);
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

		public static void DrawPartialTexture(Texture2D texture, Rectangle src, float x, float y, float width, float height, float rot, float scale, Color color)
		{
			Rectangle dest = Rectangle(x, y, width, height);
			// this will need some work to make useable with rotations (consider the origin should be the center?)
			DrawTexturePro(texture, src, dest, Vector2(0.0f, 0.0f), 0.0f, color);
		}

		public static void DrawPartialTextureCentered(Texture2D texture, Rectangle src, float x, float y, float width, float height, float rot, float scale, Color color)
		{
			Rectangle dest = Rectangle(x - width/2.0f, y - height/2.0f, width, height);
			// this will need some work to make useable with rotations (consider the origin should be the center?)
			DrawTexturePro(texture, src, dest, Vector2(0.0f, 0.0f), 0.0f, color);
		}


		public static void UpdateSpriteSheet(ref SpriteSheet spriteSheet, float dt)
		{
			spriteSheet.Timer += dt;
			if (spriteSheet.Timer >= spriteSheet.FrameTime)
			{
				spriteSheet.Timer = 0.0f;
				spriteSheet.CurrentFrame = (spriteSheet.CurrentFrame + 1) % spriteSheet.TotalFrames;
				spriteSheet.CurrentRect = Rectangle(spriteSheet.CurrentFrame * spriteSheet.FrameWidth, 0.0f, spriteSheet.FrameWidth, spriteSheet.FrameHeight);
			}
		}

		public static int Main()
		{
			int32 screenWidth = 1280;
			int32 screenHeight = 720;
			float gameTimer = 0.0f;
			//SetTraceLogLevel();
			InitWindow(screenWidth, screenHeight, "Moonraker");
			SetTargetFPS(60);

			int maxDots = 6;
			int maxClouds = 12;
			GunbarrelDot[] dots = new GunbarrelDot[maxDots];
			for (int i = 0; i < maxDots; i++)
			{
				dots[i] = new GunbarrelDot(Vector2(i*(screenWidth - 100.0f)/maxDots, 300.0f), 0.0f, false);
			}

			Vector2[] clouds = new Vector2[maxClouds];
			
			for (int i = 0; i < maxClouds; i++)
			{
				int32 randPos = GetRandomValue(0, screenWidth);
				clouds[i] = Vector2(randPos, screenHeight * (i ) / ( maxClouds));
			}

			int dotCounter = 0;
			GunbarrelDot dotStart = dots[dotCounter];
			GunbarrelDot nextDot = dots[dotCounter];
			float dotTimeout = 0.7f;
			float dotSpeed = 350.0f;
			float dotRad = 40.0f;

			bool dotStopped = false;
			int dotGrowthCounter = 0;
			float dotGrowthTimerMax = 0.5f;
			float dotGrowthTimer = 0.0f;


			//GameState gGameState = GameState.GUNBARREL_SCREEN;
			GameState gGameState = GameState.SKYDIVING_SCREEN;
			Texture2D gunbarrelTexture = LoadTexture("gunbarrel.png");
			Texture2D rogerTexture = LoadTexture("adjusted_roger_resized.png");
			Texture2D cloudTexture = LoadTexture("cloud.png");
			Texture2D rogerSkyDiveTexture = LoadTexture("rogerskydive.png");

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
			Vector2 rogerPosition = Vector2(circLoc.x, circLoc.y);

			Vector2 cloudPosition = Vector2(40.0f, 40.0f);
			SetShaderValue(gbShader, gbCircLoc, (void*)&circLoc, ShaderUniformDataType.SHADER_UNIFORM_VEC2);
			SetShaderValue(gbShader, gbTimerLoc, (void*)&circTimer, ShaderUniformDataType.SHADER_UNIFORM_FLOAT);
			SetShaderValue(slShader, slCircLoc, (void*)&circLoc, ShaderUniformDataType.SHADER_UNIFORM_VEC2);
			float cloudSpeed = -500.0f;
			float cloudEnd = (float)screenHeight + 10.0f;
			float cloudStart = -150.0f;

			Vector2 rogerDirection = Vector2(0.0f, 0.0f);
			SpriteSheet rogerSpriteSheet = new SpriteSheet(0, 16, 0.0f, 0.125f, 128.0f, 128.0f);

			SpriteSheet rogerSpriteSheetSkyDive = new SpriteSheet(0, 1, 0.0f, 0.125f, 128.0f, 128.0f);

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
						// also update the control
						if (dotStopped)
						{
							rogerDirection.x = 0.0f;
							rogerDirection.y = 0.0f;
							if (IsKeyDown(KeyboardKey.KEY_A))
							{
								rogerDirection.x = -1.0f;
							}
							if (IsKeyDown(KeyboardKey.KEY_D))
							{
								rogerDirection.x = 1.0f;
							}
							float rogerSpeed = 200.0f;
							rogerPosition.x += rogerDirection.x * dt * rogerSpeed;

							if (rogerDirection.x != 0.0f)
							{
								UpdateSpriteSheet(ref rogerSpriteSheet, dt*1.5f);
							}
						}

						break;
					case (GameState.SKYDIVING_SCREEN):
						// set blue sky background
						for (int i = 0; i < clouds.Count; i++)
						{
							Vector2 cloudPos = clouds[i];
							cloudPos.y += dt * cloudSpeed;
							if (cloudPos.y <= cloudStart)
							{
								cloudPos.y = cloudEnd;
								cloudPos.x = (float)GetRandomValue(0, screenHeight);
							}
							clouds[i] = cloudPos;

							rogerDirection.x = 0.0f;
							rogerDirection.y = 0.0f;
							if (IsKeyDown(KeyboardKey.KEY_A))
							{
								rogerDirection.x = -1.0f;
							}
							if (IsKeyDown(KeyboardKey.KEY_D))
							{
								rogerDirection.x = 1.0f;
							}

							if (IsKeyDown(KeyboardKey.KEY_W))
							{
								rogerDirection.y = -1.0f;
							}
							if (IsKeyDown(KeyboardKey.KEY_S))
							{
								rogerDirection.y = 1.0f;
							}

							
							float rogerSpeedAir = 50.0f;
							rogerPosition.x += rogerDirection.x * dt * rogerSpeedAir;
							rogerPosition.y += rogerDirection.y * dt * rogerSpeedAir;

							

						}
						
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
								DrawTextureEx(gunbarrelTexture, Vector2(-1800.0f + rogerPosition.x, 0.0f), 0.0f, 10.0f, Color.WHITE);
								EndShaderMode();
								// rather than a straight circle, what we actually want here is to draw
								// the Roger/Sean/Daniel/Tim/George/Pierce sprite with a circle shader on it. 
								//DrawCircle((int32)dotStart.Position.x, (int32)dotStart.Position.y, dotRad + dotGrowthTimer*200.0f, Color.WHITE);
								DrawCircle((int32)rogerPosition.x, (int32)rogerPosition.y, dotRad + dotGrowthTimer*200.0f, Color.WHITE);
								
								
								BeginShaderMode(slShader);
								//float spotlightRad = dotRad + dotGrowthTimer*200.0f;
								float spotlightRad = (dotRad + dotGrowthTimer*200.0f)/140.0f;
								SetShaderValue(slShader, slTimerLoc, (void*)&spotlightRad, ShaderUniformDataType.SHADER_UNIFORM_FLOAT);
								//DrawTextureEx(rogerTexture, Vector2(50.0f, 50.0f), 0.0f, 10.0f, Color.WHITE);
								// DrawTextureCentered(rogerTexture, rogerPosition.x - 10.0f, rogerPosition.y - 50.0f, 0.0f, 2.0f, Color.WHITE);
								
								EndShaderMode();
								DrawPartialTextureCentered(rogerTexture, rogerSpriteSheet.CurrentRect, rogerPosition.x - 10.0f, rogerPosition.y, rogerSpriteSheet.FrameWidth, rogerSpriteSheet.FrameHeight, 0.0f, 2.0f, Color.WHITE);
							}
							else
							{
								DrawCircle((int32)dotStart.Position.x, (int32)dotStart.Position.y, dotRad, Color.WHITE);
							}
						}
						break;
					case (GameState.SKYDIVING_SCREEN):
						// set blue sky background
						ClearBackground(.(50, 120, 250, 255));
						for (Vector2 cloud in clouds)
						{
							DrawTextureEx(cloudTexture, cloud, 0.0f, 5.0f, Color.WHITE);
						}
						DrawTextureEx(rogerSkyDiveTexture, rogerPosition, 0.0f, 5.0f, Color.WHITE);
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
			delete rogerSpriteSheet;

			delete clouds;
			delete rogerSpriteSheetSkyDive;
			return 0;
		}
	}
}
