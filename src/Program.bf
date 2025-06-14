
using System;
using System.Collections;
using static raylib_beef.Raylib;
using raylib_beef.Types;
using raylib_beef.Enums;
using Entities;
using BondMath;
using Game;





namespace ColdOpen
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

		static void DrawBloodExplosion(Vector2 originPosition, GameCamera gameCamera, float timer)
		{
			// how should we handle their trajectories?
			int particleCount = 30;
			for (int i = 0; i < particleCount; i++)
			{
				// create a radius effect and shoot particles
				float angle = (float)i / (float)(particleCount - 1);
				float radius = timer;
				float radiusScale = 600.0f; // make this based on impact velocity
				radius *= radiusScale;
				float angleToUse = angle*Math.PI_f + Math.PI_f;
				// we need a fall-off I think...?
				// or can make them physical chunks
				DrawCircle((int32)(originPosition.x + radius*Math.Cos(angleToUse) - gameCamera.Position.x), (int32)(originPosition.y + radius*Math.Sin(angleToUse) - gameCamera.Position.y), 5.0f + 20*(1.0f/(1.0f+timer)), Color.RED);
			}
		}

		//



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

		public static void UpdateGunbarrelControls(bool dotStopped, ref Vector2 rogerDirection, ref Vector2 rogerPosition, ref float persistentDirection, ref SpriteSheet rogerSpriteSheet, float dt)
		{
			if (!dotStopped)
			{
				return;
			}

			rogerDirection.x = 0.0f;
			rogerDirection.y = 0.0f;
			if (IsKeyDown(KeyboardKey.KEY_A))
			{
				rogerDirection.x = -1.0f;
				persistentDirection = rogerDirection.x;
			}
			if (IsKeyDown(KeyboardKey.KEY_D))
			{
				rogerDirection.x = 1.0f;
				persistentDirection = rogerDirection.x;
			}
			float rogerSpeed = 120.0f;
			rogerPosition.x += rogerDirection.x * dt * rogerSpeed;
			
			if (rogerDirection.x != 0.0f)
			{
				UpdateSpriteSheet(ref rogerSpriteSheet, dt*1.5f);
			}
			
		}

		
		public static bool UpdatePlaneScene(ref Vector2[] planeClouds, float[] planeCloudDistances, ref Vector2 planePos, ref float planeTimer, float dt, float screenWidth)
		{
			bool switchScene = false;
			planeTimer += dt;

			UpdateClouds(ref planeClouds, planeCloudDistances, dt, screenWidth);
			
			
			float planeSpeed = 130.0f;
			planePos.x -= planeSpeed * dt;

			if (planePos.x < 0.0f || IsKeyPressed(KeyboardKey.KEY_SPACE))
			{
				switchScene = true;
			}

			return switchScene;
		}

		public static void UpdateClouds(ref Vector2[] planeClouds, float[] planeCloudDistances, float dt, float screenWidth)
		{
			for (int i = 0; i < planeClouds.Count; i++)
			{
				float cloudSpeed = 100.0f * 1.0f/planeCloudDistances[i];
				planeClouds[i].x += dt * cloudSpeed;
				if (planeClouds[i].x > screenWidth+50.0f)
				{
					planeClouds[i].x = -150.0f;
				}
			}
		}

		// TODO (Cooper): rather than having individual arguments we should just pass in a gamestate struct that has everything that we need
		// so we don't have to continually modify the function parameters
		public static int UpdateSkydivingScene(ref Vector2[] clouds, Person roger, Person henchman, float dt, GameCamera camera, ProjectileManager projectileManager, AudioManager audioManager, float groundStart)
		{
			// have weapons fall from the sky that you can pick up?
			// or at least, have weapons able to be knocked out of people's hands mid air
			// and you can 'catch'/regather them. yeah, love that idea
			int switchScene = 0;
			//float groundStart = 5000.0f;

			for (int i = 0; i < clouds.Count; i++)
			{
				Vector2 cloudPos = clouds[i];
				
				if (cloudPos.y <= roger.Position.y - camera.ScreenHeight)
				{
					cloudPos.y = roger.Position.y + camera.ScreenHeight;
					cloudPos.x = (float)GetRandomValue(int32(roger.Position.x - camera.ScreenWidth), int32(roger.Position.x + camera.ScreenWidth));
				}
				clouds[i] = cloudPos;
			}
			float terminalVelocity = 1000.0f; // what was I thinking here?
			roger.Direction.x = 0.0f;
			roger.Direction.y = 0.0f;
			float rogerSpeedAir = 500.0f;

			float enemySpeedAir = 1000.0f;

			if (henchman.TimerStarted)
			{
				henchman.DeathTimer += dt;
			}

			if (henchman.Position.y < groundStart)
			{
				henchman.Velocity.y = (enemySpeedAir * dt);
				*henchman.Position += *henchman.Velocity;
			}
			else if (henchman.Health > 0)
			{
				henchman.Health = 0;
				if (!henchman.TimerStarted)
				{
					henchman.TimerStarted = true;
					henchman.AddParticleSystem(5, 50, 3.0f, 0.4f);
					audioManager.SoundsToPlay.Add("splat");
				}
			}
			


			


			// enemy choose direction

			//rogerAirRotation = 0.0f;
			if (IsKeyDown(KeyboardKey.KEY_A))
			{
				roger.Direction.x = -1.0f;
				//rogerAirRotation = -45.0f;
			}
			if (IsKeyDown(KeyboardKey.KEY_D))
			{
				roger.Direction.x = 1.0f;
				//rogerAirRotation = 45.0f;
			}

			if (IsKeyDown(KeyboardKey.KEY_W))
			{
				//rogerSpeedAir = 500.0f;
				roger.Direction.y = -1.0f;
			}
			if (IsKeyDown(KeyboardKey.KEY_S))
			{
				roger.Direction.y = 1.0f;
			}

			if (IsKeyDown(KeyboardKey.KEY_LEFT_SHIFT) && roger.Direction.x != 0.0f)
			{
				roger.IsRolling = true;
			}
			else
			{
				roger.IsRolling = false;
			}

			roger.IsShooting = false;
			if (IsKeyPressed(KeyboardKey.KEY_SPACE))
			{
				roger.IsShooting = true;
				audioManager.SoundsToPlay.Add("pistol_shot");
			}

			

			Matrix2.Vector2Normalize(ref *roger.Direction, 0.001f);
			if (roger.IsShooting)
			{
				// apply an impluse to the wrists that hold the gun
				// the wrists have a homeostatic thing where they want to return to a netural orientation
				// also spawn a projectile into the projectile manager
				DrawText("bang!", 10, 40, 16, Color.RED);
				// instead make a vector fr
				
				Vector2 spawnVel =  Matrix2.Vector2Scale(Vector2(Math.Cos(Trig.DegToRad((int)roger.AirRotation % 360)), Math.Sin(Trig.DegToRad((int)roger.AirRotation % 360))), -3000.0f);
				Vector2 spawnDirection = Matrix2.Vector2Normalized(spawnVel,0.001f);
				Vector2 spawnPos = *roger.Position + Matrix2.Vector2Scale(spawnDirection, 100.0f);
				// draw something at the spawn position to figure out why it's behaving weird
				//DrawCircle((int32)(spawnPos.x - camera.Position.x), (int32)(spawnPos.y - camera.Position.y), 5.0f, Color.GOLD);
				projectileManager.AddProjectile(spawnPos, spawnVel, 50, 50.0f);
			}
			float rotationSpeed = 75.0f;
			// this hsould have some acceleration to it too
			
			float rogerAirMotion = Math.Sin(Trig.DegToRad((int)roger.AirRotation % 360));
			float rogerAirMotionUp = Math.Cos(Trig.DegToRad((int)roger.AirRotation % 360));
			String airMotionText = scope $"AirMotion = {rogerAirMotion}";
			String airRotationText = scope $"From air rotation = {roger.AirRotation}";
			DrawText(airMotionText, 10, 10, 16, Color.RED);
			DrawText(airRotationText, 10, 20, 16, Color.RED);	
			

			// need to apply some friction
			Vector2 rogerFriction = Matrix2.Vector2Scale(*roger.Velocity, -0.8f);
			//float armPerSecond = 10.0f;
			//armOscilator += dt;
			//armAngleToOscilate = Math.Sin(armOscilator*2*Math.PI_f / armPerSecond) * 10.0f;
			float armAngleToOscilate = 5.0f;

			
			
			if (roger.TimerStarted)
			{
				roger.DeathTimer += dt;
			}
			// (TODO) : use force vectors
			if (roger.Position.y < groundStart) // i.e we are in the air
				// there is such thing as terminal velocity
				// the maximum speed attainable in the air
			{
				roger.Position.y += terminalVelocity * dt; // this is our base falling rate
				if (!roger.IsRolling)
				{
					roger.AirRotation += roger.Direction.x * dt * rotationSpeed;
					roger.Velocity.x += rogerAirMotion * dt * rogerSpeedAir;
					// this shouldn't be active when he's on the ground
					//roger.Velocity.y += roger.Direction.y * dt * rogerSpeedAir;

					//roger.Velocity.y += (10.0f * dt * rogerAirMotionUp);

					roger.Velocity.x += rogerFriction.x*dt;
					//roger.Velocity.y += rogerFriction.y*dt;
					roger.Position.x += (roger.Velocity.x) * dt;
					roger.Position.y += (roger.Velocity.y) * dt;
					//roger.Position.y += terminalVelocity * dt;
				}
				else
				{
					roger.AirRotation += roger.Direction.x * dt * rotationSpeed * 10.0f;
					//roger.Velocity.x += rogerAirMotion * dt * rogerSpeedAir;
					// this shouldn't be active when he's on the ground
					roger.Velocity.y += roger.Direction.y * dt * rogerSpeedAir;

					roger.Velocity.y += (10.0f * dt * rogerAirMotionUp);

					roger.Velocity.x += rogerFriction.x*dt;
					roger.Velocity.y += rogerFriction.y*dt;
					roger.Position.x += (roger.Velocity.x) * dt;
					roger.Position.y += (roger.Velocity.y) * dt;
					//roger.Position.y += terminalVelocity * dt;
				}
				
			}
			else if (roger.Health > 0)
			{
				roger.Health = 0;
				if (!roger.TimerStarted)
				{
					roger.TimerStarted = true;
					// and spawn particles
					roger.AddParticleSystem(10, 50, 3.0f, 0.2f);
					audioManager.SoundsToPlay.Add("splat");
				}
			}

			

			/*// come back to this later once more of the game is done
			(*roger.BaseSkeleton).Torso = *roger.Position;
			// this will need work to take into account the rotation
			CenterSkeleton(roger.BaseSkeleton, roger.OffsetSkeleton, roger.AirRotation);
			RotateLowerArm(roger.BaseSkeleton, roger.AirRotation, armAngleToOscilate);
			RotateUpperArm(roger.BaseSkeleton, roger.AirRotation, armAngleToOscilate);
			RotateLowerLeg(roger.BaseSkeleton, roger.AirRotation, armAngleToOscilate);
			//CenterSkeletonAdditional(&baseSkeleton, offsetSkeleton, rogerAirRotation, armAngleToOscilate);*/


			

			float cameraSpeed = Math.Min(Math.Abs(roger.Position.x - camera.Position.x), terminalVelocity);
			// would it be better to have a velocity for the camera?
			float rogerSpeed = roger.Velocity.Length();
			// maybe we need to CENTER him
			// might explain why it's less of an issue

			// camera code needs redoing

			// the issue I think is that he's moving faster than the camera
			// just have a unified system here where the camera has a velocity
			// and will adjust dynamically, including jumping (?) if totally out of bounds
			// for sufficient time
			if (roger.Position.x < (camera.Position.x + 300.0f))
			{
				// do we actually want abs?
				cameraSpeed = roger.Position.x - (camera.Position.x + 300.0f);
				camera.Position.x += (cameraSpeed * dt);
			} 
			else if (roger.Position.x >= (camera.Position.x + camera.ScreenWidth - 400.0f))
			{
				cameraSpeed = Math.Min(Math.Abs(roger.Position.x - (camera.Position.x + camera.ScreenWidth - 400.0f)), terminalVelocity);
				camera.Position.x += cameraSpeed * dt;
			}
			//cameraSpeed = Math.Abs(roger.Position.y - (camera.Position.y + 100.0f));
			if (roger.Position.y < (camera.Position.y + 100.0f))
			{
				cameraSpeed = Math.Min(Math.Abs(roger.Position.y - (camera.Position.y + 100.0f)), terminalVelocity);
				String camSpeedString = scope $"roger behind camera, setting to {cameraSpeed}";
				//DrawText(camSpeedString, 10, 10, 10, Color.GOLD);
				camera.Position.y -= cameraSpeed*dt;
			} 
			else if (roger.Position.y > (camera.Position.y + 3.0f*camera.ScreenHeight/4.0f ))
			{
				cameraSpeed = Math.Max(Math.Abs(roger.Position.y - (camera.Position.y + 3.0f*camera.ScreenHeight/4.0f )), terminalVelocity);
				String camSpeedString = scope $"roger ahead camera, setting to {cameraSpeed}";
				DrawText(camSpeedString, 10, 10, 10, Color.GOLD);
				camera.Position.y +=  cameraSpeed*dt;//(rogerSpeed + terminalVelocity)* dt;
			}

			projectileManager.UpdateProjectiles(dt, henchman, audioManager.SoundsToPlay);

			if (henchman.Health <= 0 && !henchman.TimerStarted)
			{
				henchman.TimerStarted = true;
				henchman.AddParticleSystem(5, 50, 3.0f, 0.4f);
			}
			

			

			return switchScene;


		}

		public static int UpdatePlaneInteriorScene(Person roger, Person doorInPlane, float doorWidth, float doorHeight, float dt, float screenWidth, ref Vector2[] planeClouds, float[] planeCloudDistances)
		{
			// multiple transition states
			// so we return int (could really be an enum)
			static float explosionTimer = 0.0f;
			float explosionTime = 3.0f;
			explosionTimer += dt;
			int switchScene = 0;
			Vector2 planePressurePoint = Vector2(935.0f, 304.0f);

			roger.Direction.x = 0.0f;
			roger.Direction.y = 0.0f;

			float boundMinX = 50.0f;
			float boundMaxX = 1200.0f;
			float boundMinY = 348.0f;
			float boundMaxY = 548.0f;

			if (IsKeyDown(KeyboardKey.KEY_A))
			{
				roger.Direction.x = -1.0f;
			}
			if (IsKeyDown(KeyboardKey.KEY_D))
			{
				roger.Direction.x = 1.0f;
			}

			if (IsKeyDown(KeyboardKey.KEY_W))
			{
				roger.Direction.y = -1.0f;
			}
			if (IsKeyDown(KeyboardKey.KEY_S))
			{
				roger.Direction.y = 1.0f;
			}

			if (explosionTimer <= explosionTime)
			{
				
				if (roger.Direction.Length() > 0.0001f)
				{
					// normalize and move
					float moveSpeed = 500.0f;
					*roger.Direction =  roger.Direction.Normalize(*roger.Direction);
					*roger.Direction = Matrix2.Vector2Scale(*roger.Direction, dt * moveSpeed);
					Vector2 newPosition = *roger.Position + *roger.Direction;

					if (newPosition.x > boundMinX && newPosition.x < boundMaxX &&
							newPosition.y > boundMinY && newPosition.y < boundMaxY)
					{
						*roger.Position += (*roger.Direction);
					}
					else if (newPosition.x > boundMinX && newPosition.x < boundMaxX)
					{
						roger.Position.x = newPosition.x;
						// resolve
					}
					else if (newPosition.y > boundMinY && newPosition.y < boundMaxY)
					{
						roger.Position.y = newPosition.y;
					}
					
				}
			}
			else
			{

				if (roger.Direction.Length() > 0.0001f)
				{
					// normalize and move
					float moveSpeed = 500.0f;
					*roger.Direction =  roger.Direction.Normalize(*roger.Direction);
					*roger.Direction = Matrix2.Vector2Scale(*roger.Direction, dt * moveSpeed);
					
					*roger.Position += (*roger.Direction);
					
					
				}

				switchScene = 1;
				float moveSpeed = 3000.0f;
				float distToPoint = Matrix2.Vector2Distance(planePressurePoint, *roger.Position);
				Vector2 directionToPressurePoint = (planePressurePoint -(*roger.Position));
				directionToPressurePoint = directionToPressurePoint.Normalize(directionToPressurePoint);
				directionToPressurePoint = Matrix2.Vector2Scale(directionToPressurePoint, dt * moveSpeed );
				Vector2 doorDirection = Vector2(-1.0f, 0.0f);
				float doorSpeed = 3000.0f;
				*doorInPlane.Position -= Matrix2.Vector2Scale(doorDirection, dt * doorSpeed);
				if (distToPoint >= 50.0f)
				{
					*roger.Position += directionToPressurePoint;
				}
				else
				{
					switchScene = 2;
				}

			}

			

			

			UpdateClouds(ref planeClouds, planeCloudDistances, dt, screenWidth);

			// really nice effect I somehow got where he ends up where he
			// spawns next scene, kinda seamless

			return switchScene;
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

		public static void DrawParticleSystemPerson(Person person, GameCamera gameCamera, float dt)
		{
			for (int i = 0; i < person.Particles.Count; i++)
			{
				Particle particle = person.Particles[i];
				if (person.DeathTimer >= particle.LifetimeStart &&
					person.DeathTimer <= particle.LifetimeEnd)
				{
					// add gravity
					Vector2 gravity = Vector2(0.0f, 2200.0f*dt);
					particle.Velocity += gravity;
					particle.Position += Matrix2.Vector2Scale(particle.Velocity, dt);
					DrawCircle((int32)(particle.Position.x - gameCamera.Position.x), (int32)(particle.Position.y - gameCamera.Position.y), 3.0f, Color.RED);
					person.Particles[i] = particle;
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
			Rectangle dest = Rectangle(x - (width*scale)/2.0f, y - (height*scale)/2.0f, width*scale, height*scale);
			// this will need some work to make useable with rotations (consider the origin should be the center?)
			DrawTexturePro(texture, src, dest, Vector2(0.0f, 0.0f), 0.0f, color);
		}

		public static void DrawPartialTextureCenteredFlipped(Texture2D texture, Rectangle src, float x, float y, float width, float height, float rot, float scale, Color color)
		{
			Rectangle src_to_use = Rectangle(src.x, src.y, -src.width, src.height);
			Rectangle dest = Rectangle(x - (width*scale)/2.0f, y - (height*scale)/2.0f, width*scale, height*scale);
			// this will need some work to make useable with rotations (consider the origin should be the center?)
			DrawTexturePro(texture, src_to_use, dest, Vector2(0.0f, 0.0f), 0.0f, color);
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

		

		public static void DrawMouseDebug()
		{
			Vector2 mousePos = GetMousePosition();
			String mousePosText = scope $"X={mousePos.x} Y= {mousePos.y}";
			DrawText(mousePosText, 10, 10, 20, Color.PINK);
		}

		public static void DrawVector2Debug(Vector2 vec, int32 startX, int32 startY)
		{
			String mousePosText = scope $"X={vec.x} Y= {vec.y}";
			DrawText(mousePosText, startX, startY, 20, Color.PINK);
		}
		

		public static int Main()
		{
			
			int32 screenWidth = 1920;
			int32 screenHeight = 1080;
			float gameTimer = 0.0f;
			//SetTraceLogLevel();
			InitWindow(screenWidth, screenHeight, "Moonraker");
			InitAudioDevice();
			SetTargetFPS(60);

		
			int maxBullets = 8096;
			
			ProjectileManager projectileManager = new ProjectileManager(maxBullets);
			AudioManager audioManager = new AudioManager();
			// is it wise to pass the screen dimensions to the game resources?
			// I think so since the shaders and stuff wanna know about that stuff
			GameResources gameResources = new GameResources(screenWidth, screenHeight);
			

			

			
			// emacs comment
			// GameState gGameState = GameState.GUNBARREL_SCREEN;
			GameState gGameState = GameState.SKYDIVING_SCREEN;
			

			float groundStart = 50000.0f;

			// pull these into a singular Roger
			Vector2 rogerDirection = Vector2(0.0f, 0.0f);
			Vector2 cameraPosition = Vector2(0.0f, 0.0f); // this will act as our offset
			GameCamera gameCamera = new GameCamera(cameraPosition, screenWidth, screenHeight);
			Vector2 rogerVelocity = Vector2(0.0f, 0.0f);

			

			GunbarrelScene gunbarrelScene = new GunbarrelScene(6, gameResources); // 6 max dots
			PlaneScene planeScene = new PlaneScene(gameResources, screenWidth, screenHeight);
			SkydivingScene skydivingScene = new SkydivingScene(100, 100, screenWidth, screenHeight, cameraPosition);

			

			
			
			MainWhileLoop:
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
						gGameState = gunbarrelScene.Update(dt, gGameState);

						break;
					case (GameState.PLANE_SCREEN):
						bool switchScene = planeScene.Update(dt, (float)screenWidth);
						if (switchScene)
						{
							gGameState = GameState.SKYDIVING_SCREEN;
						}
						break;
					case (GameState.SKYDIVING_SCREEN):
						int switchScene = skydivingScene.Update();
					default:
						// UpdateMGMScreen();
						gGameState = gunbarrelScene.Update(dt, gGameState);
						break;
					}


				}

				Draw:
				{
					// BeginDrawing();
					// ClearBackground(.(0, 0, 0, 255));
					float dt = GetFrameTime();
					switch (gGameState)
					{
					case (GameState.MGM_SCREEN):
						DrawMGMScreen();
						break;
					case (GameState.GUNBARREL_SCREEN):
						{
							//ClearBackground(.(29, 28, 39, 255));
							// todo: move all this somewhere clean
							gunbarrelScene.Render(gameResources);
						}
						break;
					case (GameState.PLANE_SCREEN):
						{
							planeScene.Render(gameResources);
						}
						break;
					case (GameState.SKYDIVING_SCREEN):
						{
						skydivingScene.Render(gameResources);
						}
						break;
					 	
					default:
						UpdateMGMScreen();
						break;
					}
					// EndDrawing();

				}
				
			}


			delete gunbarrelScene;
			delete planeScene;
			delete skydivingScene;

			delete gameCamera.Position;
			delete gameCamera;

		

			delete projectileManager;

			delete gameResources;
			

		
			delete audioManager;
			return 0;
		}
	}
}
