using System;
using static raylib_beef.Raylib;
using raylib_beef.Types;
using raylib_beef.Enums;

// dots should only disappear when new one is spawning
// check this on other handware to make sure
// grapple/punch system, make fun combat
// make the speed more physics-y
// make the animation more code driven


namespace BondProject
{
	class Program
	{
		public enum GameState
		{
			MGM_SCREEN,
			GUNBARREL_SCREEN,
			SKYDIVING_SCREEN,
			SKELETAL_EDITOR,
			NUM_STATES
		}

		public enum SkeletalEditorState
		{
			WHOLE_BODY,
			TORSO,
			UPPER_LEG,
			LOWER_LEG,
			UPPER_ARM,
			LOWER_ARM,
			HEAD,
			NUM_STATES,
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

		
		class Skeleton
		{

			public Vector2 Torso {get;set;}
			public Vector2 Head {get;set;}
			public Vector2 UpperArm {get;set;}
			public Vector2 LowerArm {get;set;}
			public Vector2 UpperLeg {get;set;}
			public Vector2 LowerLeg {get;set;}
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

		static float Vector2Length(Vector2 a)
		{
			return Math.Sqrt(a.x*a.x + a.y*a.y);
		}

		static void Vector2Normalize(ref Vector2 a, float tolerance)
		{
			if (Vector2Length(a) <= tolerance)
			{
				return;
			}

			float len = Vector2Length(a);
			a.x /= len;
			a.y /= len;
		}

		static float Vector2Distance(Vector2 a, Vector2 b)
		{
			return Math.Sqrt((a.x - b.x)*(a.x - b.x) + (a.y - b.y)*(a.y - b.y));
		}

		static Vector2 Vector2Scale(Vector2 a, float s)
		{

			Vector2 result = Vector2(a.x * s, a.y * s);
			return result;
		}

		static Vector2 Vector2Subtract(Vector2 a, Vector2 b)
		{
			// a - b
			Vector2 result = Vector2(a.x - b.x, a.y - b.y);
			return result;
		}

		static Vector2 Vector2Add(Vector2 a, Vector2 b)
		{
			// a - b
			Vector2 result = Vector2(a.x + b.x, a.y + b.y);
			return result;
		}

		static float DegToRad(float deg)
		{
			return Math.PI_f * deg / 180.0f;
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
			GameState gGameState = GameState.SKELETAL_EDITOR;
			Texture2D gunbarrelTexture = LoadTexture("gunbarrel.png");
			Texture2D rogerTexture = LoadTexture("adjusted_roger_resized.png");
			Texture2D cloudTexture = LoadTexture("cloud.png");
			Texture2D rogerSkyDiveTexture = LoadTexture("rogerskydive.png");

			Texture2D rogerHeadTexture = LoadTexture("head.png");
			Texture2D rogerTorsoTexture = LoadTexture("torso.png");
			Texture2D rogerUpperArmTexture = LoadTexture("upperarm.png");
			Texture2D rogerLowerArmTexture = LoadTexture("lowerarm.png");
			Texture2D rogerUpperLegTexture = LoadTexture("upperleg.png");
			Texture2D rogerLowerLegTexture = LoadTexture("lowerleg.png");


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
			Vector2 cameraPosition = Vector2(0.0f, 0.0f); // this will act as our offset
			Vector2 rogerVelocity = Vector2(0.0f, 0.0f);

			SpriteSheet rogerSpriteSheet = new SpriteSheet(0, 16, 0.0f, 0.125f, 128.0f, 128.0f);

			SpriteSheet rogerSpriteSheetSkyDive = new SpriteSheet(0, 1, 0.0f, 0.125f, 128.0f, 128.0f);

			float rogerAirRotation = 0.0f;

			float headOffsetToSave = -50.0f;
			float torsoOffsetToSave = 0.0f;
			float upperArmOffsetToSave = -100.0f;
			float lowerArmOffsetToSave = -150.0f;
			float upperLegOffsetToSave = 80.0f;
			float lowerLegOffsetToSave = 150.0f;

			Vector2 rogerTorsoPosition = Vector2(rogerPosition.x, rogerPosition.y);
			Vector2 rogerHeadPosition = Vector2(rogerPosition.x, rogerPosition.y);
			Vector2 rogerUpperArmPosition = Vector2(rogerPosition.x, rogerPosition.y);
			Vector2 rogerLowerArmPosition = Vector2(rogerPosition.x, rogerPosition.y);
			Vector2 rogerUpperLegPosition = Vector2(rogerPosition.x, rogerPosition.y);
			Vector2 rogerLowerLegPosition = Vector2(rogerPosition.x, rogerPosition.y);

			SkeletalEditorState skeletalEditorState = SkeletalEditorState.TORSO;

			bool needSave = false;


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
							float rogerSpeed = 120.0f;
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
							
							if (cloudPos.y <= cloudStart)
							{
								cloudPos.y = cloudEnd;
								cloudPos.x = (float)GetRandomValue(int32(rogerPosition.x - screenWidth), int32(rogerPosition.x + screenWidth));
							}
							clouds[i] = cloudPos;

							rogerDirection.x = 0.0f;
							rogerDirection.y = 0.0f;
							float rogerSpeedAir = 50.0f;
							//rogerAirRotation = 0.0f;
							if (IsKeyDown(KeyboardKey.KEY_A))
							{
								rogerDirection.x = -1.0f;
								//rogerAirRotation = -45.0f;
							}
							if (IsKeyDown(KeyboardKey.KEY_D))
							{
								rogerDirection.x = 1.0f;
								//rogerAirRotation = 45.0f;
							}

							if (IsKeyDown(KeyboardKey.KEY_W))
							{
								rogerSpeedAir = 100.0f;
								rogerDirection.y = -1.0f;
							}
							if (IsKeyDown(KeyboardKey.KEY_S))
							{
								rogerDirection.y = 1.0f;
							}

							Vector2Normalize(ref rogerDirection, 0.001f);
							float rotationSpeed = 5.0f;
							rogerAirRotation += rogerDirection.x * dt * rotationSpeed;
							float rogerAirMotion = Math.Sin(DegToRad(rogerAirRotation % 180));
							float rogerAirMotionUp = Math.Cos(DegToRad(rogerAirRotation % 180));
							
							rogerVelocity.x += rogerAirMotion * dt * rogerSpeedAir;
							rogerVelocity.y += rogerDirection.y * dt * rogerSpeedAir;

							rogerVelocity.y += (10.0f * dt * rogerAirMotionUp);

							// todo : Make sidways motion a function of the angle you're facing
							// think about the force diagram,

							// also let's make the camera motion actually interesting, possibly even with cuts


							
							
							// need to apply some friction
							Vector2 rogerFriction = Vector2Scale(rogerVelocity, -0.8f);
							rogerVelocity.x += rogerFriction.x*dt;
							rogerVelocity.y += rogerFriction.y*dt;
							rogerPosition.x += (rogerVelocity.x) * dt;
							rogerPosition.y += (rogerVelocity.y) * dt;

							float terminalVelocity = 0.0f;
							rogerPosition.y += terminalVelocity * dt;

							float cameraSpeed = Math.Abs(rogerPosition.x - cameraPosition.x);
							if (rogerPosition.x < (cameraPosition.x + 100.0f))
							{
								
								cameraPosition.x -= cameraSpeed * dt;
							} 
							else if (rogerPosition.x >= (cameraPosition.x + screenWidth - 100.0f))
							{
								cameraSpeed = Math.Abs(rogerPosition.x - (cameraPosition.x + screenWidth - 100.0f));
								cameraPosition.x += cameraSpeed * dt;
							}
							cameraSpeed = Math.Abs(rogerPosition.y - (cameraPosition.y + 100.0f));
							if (rogerPosition.y < (cameraPosition.y + 100.0f))
							{
								
								cameraPosition.y -= cameraSpeed * dt;
							} 
							else if (rogerPosition.y >= (cameraPosition.y + screenHeight - 100.0f))
							{
								cameraSpeed = Math.Abs(rogerPosition.y - (cameraPosition.y + screenHeight - 100.0f));
								cameraPosition.y += cameraSpeed * dt;
							}

							

							// rogerPosition.y = Math.Min(screenHeight-50.0f, rogerPosition.y);
							// rogerPosition.y = Math.Max(50.0f, rogerPosition.y);

						}
						
						break;
					case GameState.SKELETAL_EDITOR:
						Vector2 toAdd = Vector2(0.0f, 0.0f);
						if (IsKeyPressed(KeyboardKey.KEY_F1))
						{
							skeletalEditorState--;
							skeletalEditorState = Math.Max(0, skeletalEditorState);
						}
						if (IsKeyPressed(KeyboardKey.KEY_F2))
						{
							skeletalEditorState++;
							skeletalEditorState = Math.Min(skeletalEditorState, SkeletalEditorState.NUM_STATES-1);
						}
						if (IsKeyPressed(KeyboardKey.KEY_F5))
						{
							needSave = true;
						}
						if (IsKeyDown(KeyboardKey.KEY_LEFT))
						{
							toAdd.x = -1.0f;
						}
						if (IsKeyDown(KeyboardKey.KEY_RIGHT))
						{
							toAdd.x = 1.0f;
						}
						if (IsKeyDown(KeyboardKey.KEY_UP))
						{
							toAdd.y = -1.0f;
						}
						if (IsKeyDown(KeyboardKey.KEY_DOWN))
						{
							toAdd.y = 1.0f;
						}
						toAdd = Vector2Scale(toAdd, dt * 40.0f);
						switch (skeletalEditorState)
						{
						case SkeletalEditorState.WHOLE_BODY:
							rogerPosition = Vector2Add(rogerPosition, toAdd);
							break;
						case SkeletalEditorState.HEAD:
							rogerHeadPosition = Vector2Add(rogerHeadPosition, toAdd);
							break;
						case SkeletalEditorState.TORSO:
							rogerTorsoPosition = Vector2Add(rogerTorsoPosition, toAdd);
							break;
						case SkeletalEditorState.UPPER_ARM:
							rogerUpperArmPosition = Vector2Add(rogerUpperArmPosition, toAdd);
							break;
						case SkeletalEditorState.LOWER_ARM:
							rogerLowerArmPosition = Vector2Add(rogerLowerArmPosition, toAdd);
							break;
						case SkeletalEditorState.UPPER_LEG:
							rogerUpperLegPosition = Vector2Add(rogerUpperLegPosition, toAdd);
							break;
						case SkeletalEditorState.LOWER_LEG:
							rogerLowerLegPosition = Vector2Add(rogerLowerLegPosition, toAdd);
							break;
						default:
							break;
						}
						if (needSave)
						{
							System.IO.BufferedFileStream bufferedStream = new System.IO.BufferedFileStream();
							bufferedStream.Create("skeleton.bin");
							Skeleton skeleton = new Skeleton();
							skeleton.Head = rogerHeadPosition;
							skeleton.Torso = rogerTorsoPosition;
							skeleton.UpperArm = rogerUpperArmPosition;
							skeleton.LowerArm = rogerLowerArmPosition;
							skeleton.UpperLeg = rogerUpperLegPosition;
							skeleton.LowerLeg = rogerLowerLegPosition;
							
							bufferedStream.Write(skeleton.Head);
							bufferedStream.Write(skeleton.Torso);
							bufferedStream.Write(skeleton.UpperArm);
							bufferedStream.Write(skeleton.LowerArm);
							bufferedStream.Write(skeleton.UpperLeg);
							bufferedStream.Write(skeleton.LowerLeg);
							bufferedStream.Close();
							needSave = false;
						}
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
								DrawPartialTextureCentered(rogerTexture, rogerSpriteSheet.CurrentRect, rogerPosition.x - 50.0f, rogerPosition.y, rogerSpriteSheet.FrameWidth, rogerSpriteSheet.FrameHeight, 0.0f, 2.0f, Color.WHITE);
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
							//cloud.x = cloud.x - cameraPosition.x;
							DrawTextureEx(cloudTexture, Vector2Subtract(cloud, cameraPosition), 0.0f, 5.0f, Color.WHITE);
						}
						//DrawTextureEx(rogerSkyDiveTexture, rogerPosition, rogerAirRotation, 3.0f, Color.WHITE);
						//DrawTexturePro(rogerSkyDiveTexture, Rectangle(0.0f, 0.0f, 128.0f, 128.0f), Rectangle(rogerPosition.x - cameraPosition.x, rogerPosition.y - cameraPosition.y, 128.0f, 128.0f),Vector2(64.0f, 64.0f), rogerAirRotation, Color.WHITE);

						// debug draw the skeletal parts
						float headOffset = -50.0f;
						float torsoOffset = 0.0f;
						float upperArmOffset = -100.0f;
						float lowerArmOffset = -150.0f;
						float upperLegOffset = 80.0f;
						float lowerLegOffset = 150.0f;

						// think about the rotation point
						// but also think like, actual skeletal system

						DrawTexturePro(rogerHeadTexture, Rectangle(0.0f, 0.0f, 32.0f, 32.0f), Rectangle(rogerPosition.x - cameraPosition.x + headOffset, rogerPosition.y - cameraPosition.y, 128.0f, 128.0f),Vector2(64.0f, 64.0f), rogerAirRotation, Color.WHITE);
						DrawTexturePro(rogerTorsoTexture, Rectangle(0.0f, 0.0f, 32.0f, 32.0f), Rectangle(rogerPosition.x - cameraPosition.x + torsoOffset, rogerPosition.y - cameraPosition.y, 128.0f, 128.0f),Vector2(64.0f, 64.0f), rogerAirRotation, Color.WHITE);
						DrawTexturePro(rogerUpperArmTexture, Rectangle(0.0f, 0.0f, 32.0f, 32.0f), Rectangle(rogerPosition.x - cameraPosition.x + upperArmOffset, rogerPosition.y - cameraPosition.y, 128.0f, 128.0f),Vector2(64.0f, 64.0f), rogerAirRotation, Color.WHITE);
						DrawTexturePro(rogerLowerArmTexture, Rectangle(0.0f, 0.0f, 32.0f, 32.0f), Rectangle(rogerPosition.x - cameraPosition.x + lowerArmOffset, rogerPosition.y - cameraPosition.y, 128.0f, 128.0f),Vector2(64.0f, 64.0f), rogerAirRotation, Color.WHITE);
						DrawTexturePro(rogerUpperLegTexture, Rectangle(0.0f, 0.0f, 32.0f, 32.0f), Rectangle(rogerPosition.x - cameraPosition.x + upperLegOffset, rogerPosition.y - cameraPosition.y, 128.0f, 128.0f),Vector2(64.0f, 64.0f), rogerAirRotation, Color.WHITE);
						DrawTexturePro(rogerLowerLegTexture, Rectangle(0.0f, 0.0f, 32.0f, 32.0f), Rectangle(rogerPosition.x - cameraPosition.x + lowerLegOffset, rogerPosition.y - cameraPosition.y, 128.0f, 128.0f),Vector2(64.0f, 64.0f), rogerAirRotation, Color.WHITE);

						break;
					case GameState.SKELETAL_EDITOR:
						ClearBackground(.(50, 120, 250, 255));
						switch (skeletalEditorState)
						{
						case SkeletalEditorState.WHOLE_BODY:
							DrawText("whole body", 10, 10, 12, Color.WHITE);
							break;
						case SkeletalEditorState.HEAD:
							DrawText("head", 10, 10, 12, Color.WHITE);
							break;
						case SkeletalEditorState.TORSO:
							DrawText("torso", 10, 10, 12, Color.WHITE);
							break;
						case SkeletalEditorState.UPPER_ARM:
							DrawText("upper arm", 10, 10, 12, Color.WHITE);
							break;
						case SkeletalEditorState.LOWER_ARM:
							DrawText("lower arm", 10, 10, 12, Color.WHITE);
							break;
						case SkeletalEditorState.UPPER_LEG:
							DrawText("upper leg", 10, 10, 12, Color.WHITE);
							break;
						case SkeletalEditorState.LOWER_LEG:
							DrawText("lower leg", 10, 10, 12, Color.WHITE);
							break;
						default:
						}
						
						DrawTexturePro(rogerTorsoTexture, Rectangle(0.0f, 0.0f, 32.0f, 32.0f), Rectangle(rogerPosition.x - cameraPosition.x + torsoOffsetToSave, rogerPosition.y - cameraPosition.y, 128.0f, 128.0f),Vector2(64.0f, 64.0f), rogerAirRotation, Color.WHITE);
						DrawTexturePro(rogerUpperArmTexture, Rectangle(0.0f, 0.0f, 32.0f, 32.0f), Rectangle(rogerPosition.x - cameraPosition.x + upperArmOffsetToSave, rogerPosition.y - cameraPosition.y, 128.0f, 128.0f),Vector2(64.0f, 64.0f), rogerAirRotation, Color.WHITE);
						DrawTexturePro(rogerLowerArmTexture, Rectangle(0.0f, 0.0f, 32.0f, 32.0f), Rectangle(rogerPosition.x - cameraPosition.x + lowerArmOffsetToSave, rogerPosition.y - cameraPosition.y, 128.0f, 128.0f),Vector2(64.0f, 64.0f), rogerAirRotation, Color.WHITE);
						DrawTexturePro(rogerUpperLegTexture, Rectangle(0.0f, 0.0f, 32.0f, 32.0f), Rectangle(rogerPosition.x - cameraPosition.x + upperLegOffsetToSave, rogerPosition.y - cameraPosition.y, 128.0f, 128.0f),Vector2(64.0f, 64.0f), rogerAirRotation, Color.WHITE);
						DrawTexturePro(rogerLowerLegTexture, Rectangle(0.0f, 0.0f, 32.0f, 32.0f), Rectangle(rogerPosition.x - cameraPosition.x + lowerLegOffsetToSave, rogerPosition.y - cameraPosition.y, 128.0f, 128.0f),Vector2(64.0f, 64.0f), rogerAirRotation, Color.WHITE);
						DrawTexturePro(rogerHeadTexture, Rectangle(0.0f, 0.0f, 32.0f, 32.0f), Rectangle(rogerPosition.x - cameraPosition.x + headOffsetToSave, rogerPosition.y - cameraPosition.y, 128.0f, 128.0f),Vector2(64.0f, 64.0f), rogerAirRotation, Color.WHITE);
						DrawCircle((int32)rogerTorsoPosition.x, (int32)rogerTorsoPosition.y, 5.0f, Color.RED);
						DrawCircle((int32)rogerHeadPosition.x, (int32)rogerHeadPosition.y, 5.0f, Color.RED);
						DrawCircle((int32)rogerUpperArmPosition.x, (int32)rogerUpperArmPosition.y, 5.0f, Color.RED);
						DrawCircle((int32)rogerLowerArmPosition.x, (int32)rogerLowerArmPosition.y, 5.0f, Color.RED);
						DrawCircle((int32)rogerUpperLegPosition.x, (int32)rogerUpperLegPosition.y, 5.0f, Color.RED);
						DrawCircle((int32)rogerLowerLegPosition.x, (int32)rogerLowerLegPosition.y, 5.0f, Color.RED);
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
