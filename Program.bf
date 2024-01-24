using System;
using static raylib_beef.Raylib;
using raylib_beef.Types;
using raylib_beef.Enums;
using Entities;
using BondMath;



// dots should only disappear when new one is spawning
// check this on other handware to make sure
// grapple/punch system, make fun combat
// make the speed more physics-y
// make the animation more code driven

// start on a plane


namespace BondProject
{
	class Program
	{

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



		static void TranslateSkeleton(Vector2 trans, Skeleton *skeleton)
		{

			(*skeleton).Torso = Matrix2.Vector2Add(trans, (*skeleton).Torso);
			(*skeleton).UpperArm = Matrix2.Vector2Add(trans, (*skeleton).UpperArm);
			(*skeleton).LowerArm = Matrix2.Vector2Add(trans, (*skeleton).LowerArm);
			(*skeleton).UpperLeg = Matrix2.Vector2Add(trans, (*skeleton).UpperLeg);
			(*skeleton).LowerLeg = Matrix2.Vector2Add(trans, (*skeleton).LowerLeg);
			(*skeleton).Head = Matrix2.Vector2Add(trans, (*skeleton).Head);

		}



		static void CenterSkeleton(Skeleton *skeleton, Skeleton offsetSkeleton, float angle)
		{
			// assume that the 
			//(*skeleton).Torso = Matrix2.Vector2Add(trans, (*skeleton).Torso);
			// a first step would be to add the rotated vector...?
			Vector2 upperArmRot = Matrix2.RotateVector2(offsetSkeleton.UpperArm, angle);
			Vector2 lowerArmRot = Matrix2.RotateVector2(offsetSkeleton.LowerArm, angle);
			Vector2 upperLegRot = Matrix2.RotateVector2(offsetSkeleton.UpperLeg, angle);
			Vector2 lowerLegRot = Matrix2.RotateVector2(offsetSkeleton.LowerLeg, angle);
			Vector2 headRot = Matrix2.RotateVector2(offsetSkeleton.Head, angle);

			(*skeleton).UpperArm = Matrix2.Vector2Add(upperArmRot, (*skeleton).Torso);
			(*skeleton).LowerArm = Matrix2.Vector2Add(lowerArmRot, (*skeleton).Torso);
			(*skeleton).UpperLeg = Matrix2.Vector2Add(upperLegRot, (*skeleton).Torso);
			(*skeleton).LowerLeg = Matrix2.Vector2Add(lowerLegRot, (*skeleton).Torso);
			(*skeleton).Head = Matrix2.Vector2Add(headRot, (*skeleton).Torso);

		}

		static void CenterSkeletonAdditional(Skeleton *skeleton, Skeleton offsetSkeleton, float angle, float additionalLowerArm)
		{
			// assume that the 
			//(*skeleton).Torso = Matrix2.Vector2Add(trans, (*skeleton).Torso);
			// a first step would be to add the rotated vector...?
			Vector2 upperArmRot = Matrix2.RotateVector2(offsetSkeleton.UpperArm, angle);
			Vector2 lowerArmRot = Matrix2.RotateVector2(offsetSkeleton.LowerArm, angle + additionalLowerArm);
			Vector2 upperLegRot = Matrix2.RotateVector2(offsetSkeleton.UpperLeg, angle);
			Vector2 lowerLegRot = Matrix2.RotateVector2(offsetSkeleton.LowerLeg, angle);
			Vector2 headRot = Matrix2.RotateVector2(offsetSkeleton.Head, angle);

			(*skeleton).UpperArm = Matrix2.Vector2Add(upperArmRot, (*skeleton).Torso);
			(*skeleton).LowerArm = Matrix2.Vector2Add(lowerArmRot, (*skeleton).Torso);
			(*skeleton).UpperLeg = Matrix2.Vector2Add(upperLegRot, (*skeleton).Torso);
			(*skeleton).LowerLeg = Matrix2.Vector2Add(lowerLegRot, (*skeleton).Torso);
			(*skeleton).Head = Matrix2.Vector2Add(headRot, (*skeleton).Torso);

		}

		// Finally the shape of the hierarchical solution is starting make sense
		// so what we want is something like
		// a hierachical struct
		// 
		static void RotateAllFromRoot(Skeleton *skeleton, float baseRotation)
		{

		}

		// if we shift the torso (aka everthing), everything is rotated
		// then 

		static void RotateLowerArm(Skeleton *skeleton, float baseRotation, float additionalRotation)
		{
			// do everything in a basis space
			float armLength = 32.0f;
			Vector2 result = Vector2(1.0f, 0.0f);
			result = Matrix2.Vector2Scale(result, armLength);

			Vector2 originalRotated = Matrix2.RotateVector2(result, baseRotation);
			Vector2 additionalRotated = Matrix2.RotateVector2(originalRotated, additionalRotation);
			Vector2 difference = Matrix2.Vector2Subtract(additionalRotated, originalRotated);
			(*skeleton).LowerArm = Matrix2.Vector2Subtract((*skeleton).LowerArm, difference);
		}

		static void RotateUpperArm(Skeleton *skeleton, float baseRotation, float additionalRotation)
		{
			// do everything in a basis space
			float armLength = 32.0f;
			Vector2 result = Vector2(1.0f, 0.0f);
			result = Matrix2.Vector2Scale(result, armLength);

			Vector2 originalRotated = Matrix2.RotateVector2(result, baseRotation);
			Vector2 additionalRotated = Matrix2.RotateVector2(originalRotated, additionalRotation);
			Vector2 difference = Matrix2.Vector2Subtract(additionalRotated, originalRotated);
			(*skeleton).UpperArm = Matrix2.Vector2Subtract((*skeleton).UpperArm, difference);
		}

		static void RotateLowerLeg(Skeleton *skeleton, float baseRotation, float additionalRotation)
		{
			// do everything in a basis space
			float armLength = 64.0f;
			Vector2 result = Vector2(-1.0f, 0.0f);
			result = Matrix2.Vector2Scale(result, armLength);

			Vector2 originalRotated = Matrix2.RotateVector2(result, baseRotation);
			Vector2 additionalRotated = Matrix2.RotateVector2(originalRotated, additionalRotation);
			Vector2 difference = Matrix2.Vector2Subtract(additionalRotated, originalRotated);
			(*skeleton).LowerLeg = Matrix2.Vector2Subtract((*skeleton).LowerLeg, difference);
		}

		

		

		
		public static void UpdateGunbarrel(ref GunbarrelDot dotStart, ref GunbarrelDot nextDot, GunbarrelDot[] dots,
			ref int dotCounter, ref float circTimer, ref float dotGrowthTimer, float dotGrowthTimerMax, float dotSpeed, ref bool dotStopped,
			float dotTimeout, int maxDots, float dt)
		{
			if (dotStart.Position.x < dots[maxDots - 1].Position.x && !dotStopped)
			{
				dotStart.Position.x += dt * dotSpeed;
				if (Matrix2.Vector2Distance(*nextDot.Position, *dotStart.Position) < 3.0f && !nextDot.Active)
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

		public static void MoveBones(Bone *root)
		{
			// rotate the current one

			// pass it on to the next
			if ((*root).Children.Count > 0)
			{
				for (var bone in (*root).Children)
				{
					MoveBones(&bone); // maybe? think this one through
				}

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
			//GameState gGameState = GameState.SKELETAL_EDITOR;
			// GameState gGameState = GameState.SKYDIVING_SCREEN;
			GameState gGameState = GameState.PLANE_SCREEN;
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

			Texture2D planeTexture = LoadTexture("plane_at_scale.png");


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

			Vector2 planePosition = Vector2(40.0f, 40.0f);
			float planeRotation = 0.0f;

			Vector2 cloudPosition = Vector2(40.0f, 40.0f);
			SetShaderValue(gbShader, gbCircLoc, (void*)&circLoc, ShaderUniformDataType.SHADER_UNIFORM_VEC2);
			SetShaderValue(gbShader, gbTimerLoc, (void*)&circTimer, ShaderUniformDataType.SHADER_UNIFORM_FLOAT);
			SetShaderValue(slShader, slCircLoc, (void*)&circLoc, ShaderUniformDataType.SHADER_UNIFORM_VEC2);
			float cloudSpeed = -500.0f;
			float cloudEnd = (float)screenHeight + 10.0f;
			float cloudStart = -150.0f;

			float groundStart = 5000.0f;

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


			float armOscilator = 0.0f;
			float armAngleToOscilate = Math.Sin(armOscilator*2*Math.PI_f / 2.0f) * 10.0f;

			Vector2 rogerTorsoPosition = Vector2(rogerPosition.x, rogerPosition.y);
			Vector2 rogerHeadPosition = Vector2(rogerPosition.x, rogerPosition.y);
			Vector2 rogerUpperArmPosition = Vector2(rogerPosition.x, rogerPosition.y);
			Vector2 rogerLowerArmPosition = Vector2(rogerPosition.x, rogerPosition.y);
			Vector2 rogerUpperLegPosition = Vector2(rogerPosition.x, rogerPosition.y);
			Vector2 rogerLowerLegPosition = Vector2(rogerPosition.x, rogerPosition.y);

			// load the new skeleton and set, if it exists
			System.IO.BufferedFileStream vbufferedStream = new System.IO.BufferedFileStream();
			vbufferedStream.Open("skeleton.bin");
			Skeleton baseSkeleton = new Skeleton();
			Skeleton offsetSkeleton = new Skeleton();


			baseSkeleton.Head = vbufferedStream.Read<Vector2>();
			baseSkeleton.Torso = vbufferedStream.Read<Vector2>();
			baseSkeleton.UpperArm = vbufferedStream.Read<Vector2>();

			baseSkeleton.LowerArm = vbufferedStream.Read<Vector2>();
			baseSkeleton.UpperLeg = vbufferedStream.Read<Vector2>();
			baseSkeleton.LowerLeg = vbufferedStream.Read<Vector2>();

			// check ordering on that subtract
			offsetSkeleton.Head = Matrix2.Vector2Subtract(baseSkeleton.Head, baseSkeleton.Torso);
			offsetSkeleton.UpperArm = Matrix2.Vector2Subtract(baseSkeleton.UpperArm, baseSkeleton.Torso);
			offsetSkeleton.LowerArm = Matrix2.Vector2Subtract(baseSkeleton.LowerArm, baseSkeleton.Torso);
			offsetSkeleton.UpperLeg = Matrix2.Vector2Subtract(baseSkeleton.UpperLeg, baseSkeleton.Torso);
			offsetSkeleton.LowerLeg = Matrix2.Vector2Subtract(baseSkeleton.LowerLeg, baseSkeleton.Torso);

			vbufferedStream.Close();
			delete vbufferedStream;

			// move the torso to be at roger position
			// and then move everything else by that amount?
			
			// just use these actually
			//delete baseSkeleton;
			// then also write an update position function for each thing in it

			SkeletalEditorState skeletalEditorState = SkeletalEditorState.TORSO;

			bool needSave = false;
			bool needLoad = false;

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
					case (GameState.PLANE_SCREEN):
						break;
					case (GameState.SKYDIVING_SCREEN):
						// set blue sky background
						for (int i = 0; i < clouds.Count; i++)
						{
							Vector2 cloudPos = clouds[i];
							
							if (cloudPos.y <= rogerPosition.y - screenHeight)
							{
								cloudPos.y = rogerPosition.y + screenHeight;
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

							Matrix2.Vector2Normalize(ref rogerDirection, 0.001f);
							float rotationSpeed = 5.0f;
							rogerAirRotation += rogerDirection.x * dt * rotationSpeed;
							float rogerAirMotion = Math.Sin(Trig.DegToRad(rogerAirRotation % 180));
							float rogerAirMotionUp = Math.Cos(Trig.DegToRad(rogerAirRotation % 180));
							
							rogerVelocity.x += rogerAirMotion * dt * rogerSpeedAir;
							// this shouldn't be active when he's on the ground
							rogerVelocity.y += rogerDirection.y * dt * rogerSpeedAir;

							rogerVelocity.y += (10.0f * dt * rogerAirMotionUp);

							// todo : Make sidways motion a function of the angle you're facing
							// think about the force diagram,

							// also let's make the camera motion actually interesting, possibly even with cuts


							
							
							// need to apply some friction
							Vector2 rogerFriction = Matrix2.Vector2Scale(rogerVelocity, -0.8f);
							float armPerSecond = 10.0f;
							armOscilator += dt;
							armAngleToOscilate = Math.Sin(armOscilator*2*Math.PI_f / armPerSecond) * 10.0f;
							
							rogerVelocity.x += rogerFriction.x*dt;
							rogerVelocity.y += rogerFriction.y*dt;
							rogerPosition.x += (rogerVelocity.x) * dt;
							if (rogerPosition.y < groundStart)
							{
								rogerPosition.y += (rogerVelocity.y) * dt;
							}

							baseSkeleton.Torso = rogerPosition;
							// this will need work to take into account the rotation
							CenterSkeleton(&baseSkeleton, offsetSkeleton, rogerAirRotation);
							RotateLowerArm(&baseSkeleton, rogerAirRotation, armAngleToOscilate);
							RotateUpperArm(&baseSkeleton, rogerAirRotation, armAngleToOscilate);
							RotateLowerLeg(&baseSkeleton, rogerAirRotation, armAngleToOscilate);
							//CenterSkeletonAdditional(&baseSkeleton, offsetSkeleton, rogerAirRotation, armAngleToOscilate);


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
						if (IsKeyPressed(KeyboardKey.KEY_F6))
						{
							needLoad = true;
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
						toAdd = Matrix2.Vector2Scale(toAdd, dt * 40.0f);
						switch (skeletalEditorState)
						{
						case SkeletalEditorState.WHOLE_BODY:
							rogerPosition = Matrix2.Vector2Add(rogerPosition, toAdd);
							break;
						case SkeletalEditorState.HEAD:
							rogerHeadPosition = Matrix2.Vector2Add(rogerHeadPosition, toAdd);
							break;
						case SkeletalEditorState.TORSO:
							rogerTorsoPosition = Matrix2.Vector2Add(rogerTorsoPosition, toAdd);
							break;
						case SkeletalEditorState.UPPER_ARM:
							rogerUpperArmPosition = Matrix2.Vector2Add(rogerUpperArmPosition, toAdd);
							break;
						case SkeletalEditorState.LOWER_ARM:
							rogerLowerArmPosition = Matrix2.Vector2Add(rogerLowerArmPosition, toAdd);
							break;
						case SkeletalEditorState.UPPER_LEG:
							rogerUpperLegPosition = Matrix2.Vector2Add(rogerUpperLegPosition, toAdd);
							break;
						case SkeletalEditorState.LOWER_LEG:
							rogerLowerLegPosition = Matrix2.Vector2Add(rogerLowerLegPosition, toAdd);
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
							delete skeleton;
							delete bufferedStream;
							needSave = false;
						}

						if (needLoad)
						{
							System.IO.BufferedFileStream bufferedStream = new System.IO.BufferedFileStream();
							bufferedStream.Open("skeleton.bin");
							Skeleton skeleton = new Skeleton();
							

							skeleton.Head = bufferedStream.Read<Vector2>();
							skeleton.Torso = bufferedStream.Read<Vector2>();
							skeleton.UpperArm = bufferedStream.Read<Vector2>();
							
							skeleton.LowerArm = bufferedStream.Read<Vector2>();
							skeleton.UpperLeg = bufferedStream.Read<Vector2>();
							skeleton.LowerLeg = bufferedStream.Read<Vector2>();
							
							bufferedStream.Close();

							rogerHeadPosition = skeleton.Head ;
							rogerTorsoPosition = skeleton.Torso;
							rogerUpperArmPosition = skeleton.UpperArm;
							rogerLowerArmPosition = skeleton.LowerArm;
							rogerUpperLegPosition = skeleton.UpperLeg;
							rogerLowerLegPosition = skeleton.LowerLeg;
							delete skeleton;
							delete bufferedStream;
							needLoad = false;
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
					case (GameState.PLANE_SCREEN):
						ClearBackground(.(50, 120, 250, 255));
						DrawTextureEx(planeTexture, planePosition, planeRotation, 1.0f, Color.RAYWHITE);
						
						break;
					case (GameState.SKYDIVING_SCREEN):
						// set blue sky background
						ClearBackground(.(50, 120, 250, 255));
						for (Vector2 cloud in clouds)
						{
							//cloud.x = cloud.x - cameraPosition.x;
							DrawTextureEx(cloudTexture, Matrix2.Vector2Subtract(cloud, cameraPosition), 0.0f, 5.0f, Color.WHITE);
						}

						// draw the ground when it's in frame, or just draw it offscreen constantly
						// start by the dumb way
						DrawRectangle(0, (int32)(groundStart - cameraPosition.y), screenWidth, screenHeight, Color.DARKBROWN);

						//DrawTextureEx(rogerSkyDiveTexture, rogerPosition, rogerAirRotation, 3.0f, Color.WHITE);
						//DrawTexturePro(rogerSkyDiveTexture, Rectangle(0.0f, 0.0f, 128.0f, 128.0f), Rectangle(rogerPosition.x - cameraPosition.x, rogerPosition.y - cameraPosition.y, 128.0f, 128.0f),Vector2(64.0f, 64.0f), rogerAirRotation, Color.WHITE);

						// debug draw the skeletal parts
						float headOffset = -50.0f; // why not calculate the offset?
						float torsoOffset = 0.0f;
						float upperArmOffset = -100.0f;
						float lowerArmOffset = -150.0f;
						float upperLegOffset = 80.0f;
						float lowerLegOffset = 150.0f;

						// think about the rotation point
						// but also think like, actual skeletal system


						// TODO: make these centered 
						DrawTexturePro(rogerTorsoTexture, Rectangle(0.0f, 0.0f, 32.0f, 32.0f), Rectangle(baseSkeleton.Torso.x - cameraPosition.x, baseSkeleton.Torso.y - cameraPosition.y, 128.0f, 128.0f),Vector2(64.0f, 64.0f), rogerAirRotation, Color.WHITE);
						DrawTexturePro(rogerUpperArmTexture, Rectangle(0.0f, 0.0f, 32.0f, 32.0f), Rectangle(baseSkeleton.UpperArm.x - cameraPosition.x, baseSkeleton.UpperArm.y - cameraPosition.y, 128.0f, 128.0f),Vector2(64.0f, 64.0f), rogerAirRotation + armAngleToOscilate, Color.WHITE);
						DrawTexturePro(rogerLowerArmTexture, Rectangle(0.0f, 0.0f, 32.0f, 32.0f), Rectangle(baseSkeleton.LowerArm.x - cameraPosition.x, baseSkeleton.LowerArm.y - cameraPosition.y, 128.0f, 128.0f),Vector2(64.0f, 64.0f), rogerAirRotation + armAngleToOscilate, Color.WHITE);
						DrawTexturePro(rogerUpperLegTexture, Rectangle(0.0f, 0.0f, 32.0f, 32.0f), Rectangle(baseSkeleton.UpperLeg.x - cameraPosition.x, baseSkeleton.UpperLeg.y - cameraPosition.y, 128.0f, 128.0f),Vector2(64.0f, 64.0f), rogerAirRotation, Color.WHITE);
						DrawTexturePro(rogerLowerLegTexture, Rectangle(0.0f, 0.0f, 32.0f, 32.0f), Rectangle(baseSkeleton.LowerLeg.x - cameraPosition.x , baseSkeleton.LowerLeg.y - cameraPosition.y, 128.0f, 128.0f),Vector2(64.0f, 64.0f), rogerAirRotation + armAngleToOscilate, Color.WHITE);
						DrawTexturePro(rogerHeadTexture, Rectangle(0.0f, 0.0f, 32.0f, 32.0f), Rectangle(baseSkeleton.Head.x- cameraPosition.x , baseSkeleton.Head.y - cameraPosition.y, 128.0f, 128.0f),Vector2(64.0f, 64.0f), rogerAirRotation, Color.WHITE);

						//DrawTexturePro(rogerHeadTexture, Rectangle(0.0f, 0.0f, 32.0f, 32.0f), Rectangle(rogerPosition.x - cameraPosition.x + headOffset, rogerPosition.y - cameraPosition.y, 128.0f, 128.0f),Vector2(64.0f, 64.0f), rogerAirRotation, Color.WHITE);
						//DrawTexturePro(rogerTorsoTexture, Rectangle(0.0f, 0.0f, 32.0f, 32.0f), Rectangle(rogerPosition.x - cameraPosition.x + torsoOffset, rogerPosition.y - cameraPosition.y, 128.0f, 128.0f),Vector2(64.0f, 64.0f), rogerAirRotation, Color.WHITE);
						//DrawTexturePro(rogerUpperArmTexture, Rectangle(0.0f, 0.0f, 32.0f, 32.0f), Rectangle(rogerPosition.x - cameraPosition.x + upperArmOffset, rogerPosition.y - cameraPosition.y, 128.0f, 128.0f),Vector2(64.0f, 64.0f), rogerAirRotation, Color.WHITE);
						//DrawTexturePro(rogerLowerArmTexture, Rectangle(0.0f, 0.0f, 32.0f, 32.0f), Rectangle(rogerPosition.x - cameraPosition.x + lowerArmOffset, rogerPosition.y - cameraPosition.y, 128.0f, 128.0f),Vector2(64.0f, 64.0f), rogerAirRotation, Color.WHITE);
						//DrawTexturePro(rogerUpperLegTexture, Rectangle(0.0f, 0.0f, 32.0f, 32.0f), Rectangle(rogerPosition.x - cameraPosition.x + upperLegOffset, rogerPosition.y - cameraPosition.y, 128.0f, 128.0f),Vector2(64.0f, 64.0f), rogerAirRotation, Color.WHITE);
						//DrawTexturePro(rogerLowerLegTexture, Rectangle(0.0f, 0.0f, 32.0f, 32.0f), Rectangle(rogerPosition.x - cameraPosition.x + lowerLegOffset, rogerPosition.y - cameraPosition.y, 128.0f, 128.0f),Vector2(64.0f, 64.0f), rogerAirRotation, Color.WHITE);

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
						
						

						DrawTexturePro(rogerHeadTexture, Rectangle(0.0f, 0.0f, 32.0f, 32.0f), Rectangle(rogerHeadPosition.x- cameraPosition.x , rogerHeadPosition.y - cameraPosition.y, 128.0f, 128.0f),Vector2(64.0f, 64.0f), rogerAirRotation, Color.WHITE);
						DrawTexturePro(rogerTorsoTexture, Rectangle(0.0f, 0.0f, 32.0f, 32.0f), Rectangle(rogerTorsoPosition.x - cameraPosition.x, rogerTorsoPosition.y - cameraPosition.y, 128.0f, 128.0f),Vector2(64.0f, 64.0f), rogerAirRotation, Color.WHITE);
						DrawTexturePro(rogerUpperArmTexture, Rectangle(0.0f, 0.0f, 32.0f, 32.0f), Rectangle(rogerUpperArmPosition.x - cameraPosition.x, rogerUpperArmPosition.y - cameraPosition.y, 128.0f, 128.0f),Vector2(64.0f, 64.0f), rogerAirRotation, Color.WHITE);
						DrawTexturePro(rogerLowerArmTexture, Rectangle(0.0f, 0.0f, 32.0f, 32.0f), Rectangle(rogerLowerArmPosition.x - cameraPosition.x, rogerLowerArmPosition.y - cameraPosition.y, 128.0f, 128.0f),Vector2(64.0f, 64.0f), rogerAirRotation, Color.WHITE);
						DrawTexturePro(rogerUpperLegTexture, Rectangle(0.0f, 0.0f, 32.0f, 32.0f), Rectangle(rogerUpperLegPosition.x - cameraPosition.x, rogerUpperLegPosition.y - cameraPosition.y, 128.0f, 128.0f),Vector2(64.0f, 64.0f), rogerAirRotation, Color.WHITE);
						DrawTexturePro(rogerLowerLegTexture, Rectangle(0.0f, 0.0f, 32.0f, 32.0f), Rectangle(rogerLowerLegPosition.x - cameraPosition.x , rogerLowerLegPosition.y - cameraPosition.y, 128.0f, 128.0f),Vector2(64.0f, 64.0f), rogerAirRotation, Color.WHITE);
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
			delete baseSkeleton;
			delete offsetSkeleton;
			return 0;
		}
	}
}
