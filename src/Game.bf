using System;
using System.Collections;
using static raylib_beef.Raylib;
using raylib_beef.Types;
using raylib_beef.Enums;
using Entities;
using BondMath;

namespace Game
{

	public enum GameState
        {
            MGM_SCREEN,
            GUNBARREL_SCREEN,
            PLANE_SCREEN,
            PLANE_INTERIOR_SCREEN,
            SKYDIVING_SCREEN,
            SKELETAL_EDITOR,
            NUM_STATES
        }

    public enum RogerAnimationState
        {
            STATIONARY,
            TURNING,
            WALKING,
            UNHOLSTERING,
            AIMING, 
            SHOOTING,            
        }
    
	class GameUpdateAndRender
	{
		
		public static void Update(float dt)
		{
			
		}

		public static void Render()
		{
		}
	}


	class TextureDrawing
	{

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

    class RogerSpriteSheet
	{
        public float FrameWidth;
		public float FrameHeight;
		public Rectangle CurrentRect;
        
		public int32 CurrentFrame;
        public int32 CurrentFrameSection;
        public RogerAnimationState State;
        public bool CurrentAnimFinished = false;
        public bool CurrentAnimLoops = true;
        public bool CurrentAnimReverses = true;

        public float AnimLerp = 0.0f;

		float Timer;
		float FrameTime;

        int32 SectionStart = 0;
        int32 SectionEnd = 0;

        int32 WalkingFrameStart = 1;
        public int32 WalkingFrameEnd = 17;

        int32 TurningFrameStart = 25;
        int32 TurningFrameEnd = 28;

        int32 ShootingFrameStart = 18;
        int32 ShootingFrameEnd = 24;
        
        int32 IdleFrameStart = 0;
        int32 IdleFrameEnd = 0;
        
        int32 TotalFramesSection;

        
           
		public this(RogerAnimationState state, float timer, float frameTime, float frameWidth, float frameHeight)
		{
            SetState(state);
            Timer = timer;
			FrameTime = frameTime;
	 		FrameWidth = frameWidth;
			FrameHeight = frameHeight;
			CurrentRect = Rectangle(0.0f, 0.0f, FrameWidth, FrameHeight);
		}

        public void Reset()
        {
            CurrentFrame = 0;
            Timer = 0.0f;
            CurrentRect = Rectangle(CurrentFrame * FrameWidth, 0.0f, FrameWidth, FrameHeight);
            SetState(RogerAnimationState.STATIONARY);
        }

        public void SetState(RogerAnimationState newState, bool animLoops = true, bool animReverses = false)
        {
            State = newState;
            CurrentFrame = 0;
            CurrentAnimLoops = animLoops;
            CurrentAnimReverses = animReverses;
            
            if (State == RogerAnimationState.STATIONARY)
            {                
                SectionStart = IdleFrameStart;
                SectionEnd = IdleFrameEnd;
                
            }
            else if (State == RogerAnimationState.TURNING)
            {
                SectionStart = TurningFrameStart;
                SectionEnd = TurningFrameEnd;

            }
            else if (State == RogerAnimationState.WALKING)
            {
                SectionStart = WalkingFrameStart;
                SectionEnd = WalkingFrameEnd;

            }
            else if (State == RogerAnimationState.SHOOTING)
            {
                SectionStart = ShootingFrameStart;
                SectionEnd = ShootingFrameEnd;
            }
            else if (State == RogerAnimationState.UNHOLSTERING)
            {
                SectionStart = ShootingFrameStart;
                SectionEnd = ShootingFrameEnd;
            }

            TotalFramesSection = Math.Max(SectionEnd - SectionStart, 1);
            CurrentFrameSection = SectionStart + CurrentFrame;
            CurrentRect = Rectangle(CurrentFrameSection * FrameWidth, 0.0f, FrameWidth, FrameHeight);            
        }

        

        public void Update(float dt)
        {
            Timer += dt;
            if (Timer >= FrameTime)
            {
                Timer = 0.0f;
                if (CurrentAnimLoops)
                {
                    CurrentFrame = (CurrentFrame + 1) % TotalFramesSection; // make this in section instead
                    CurrentFrameSection = SectionStart + CurrentFrame;
                }
                else
                {
                    CurrentFrame = (int32)(AnimLerp * TotalFramesSection);
                    //CurrentFrame = Math.Min(CurrentFrame + 1,  TotalFramesSection); // make this in section instead
                    CurrentFrameSection = SectionStart + CurrentFrame;
                }
                
                String currentFrameText = scope $"current frame is {CurrentFrameSection}";
                //DrawText(currentFrameText, 10, 10, 16, Color.RED);
                // then map it to a region
                CurrentRect = Rectangle(CurrentFrameSection * FrameWidth, 0.0f, FrameWidth, FrameHeight);
            }
            
        }
            

	}

	class GameResources
	{
		public Texture2D gunbarrelBGTexture;
		public Texture2D gunbarrelTexture;
		public Texture2D rogerTexture;
		public Texture2D cloudTexture;
		public Texture2D planeInteriorTexture;

		public Texture2D rogerSkyDiveTexture;
		public Texture2D rogerHeadTexture;
		public Texture2D rogerTorsoTexture;
		public Texture2D rogerUpperArmTexture;
		public Texture2D rogerLowerArmTexture;
		public Texture2D rogerUpperLegTexture;
		public Texture2D rogerLowerLegTexture;
		public Texture2D planeTexture;

		public Texture2D henchmanTexture;

		public Sound airLoopSound;
		public Sound groundHitSound;
        public Sound gunbarrelGunshotSound;
		public Sound gunshotSound;
		public Sound gunshotHitSound;

		// why not include shaders here?

		public Shader gbShader;
        public Shader gbBackgroundShader;
		public Shader slShader;

        
		public int32 gbTexLoc;
        public int32 gbBackgroundTexLoc;
		public int32 slTexLoc;

        
		public int32 gbTimerLoc;
        public int32 gbBackgroundTimerLoc;
		public int32 gbCircLoc;        
		public int32 gbBackgroundCircLoc;

		public int32 slTimerLoc;
		public int32 slCircLoc;
        




		// SetShaderValueTexture(gbShader, gbTexLoc, gameResources.gunbarrelTexture);
		// SetShaderValueTexture(slShader, slTexLoc, gameResources.rogerTexture);
		// SetShaderValue(gbShader, gbCircLoc, (void*)&circLoc, ShaderUniformDataType.SHADER_UNIFORM_VEC2);
		// SetShaderValue(gbShader, gbTimerLoc, (void*)&circTimer, ShaderUniformDataType.SHADER_UNIFORM_FLOAT);
		// SetShaderValue(slShader, slCircLoc, (void*)&circLoc, ShaderUniformDataType.SHADER_UNIFORM_VEC2);

		public this()
		{

            Reload();
			
		}

		public ~this()
		{
		}

        public void Reload()
        {
            gunbarrelBGTexture = LoadTexture("gunbarrel.png");
			gunbarrelTexture = LoadTexture("better_gunbarrel.png");
			rogerTexture = LoadTexture("adjusted_roger_resized.png");
			cloudTexture = LoadTexture("cloud.png");
			rogerSkyDiveTexture = LoadTexture("rogerskydive.png");
			planeInteriorTexture = LoadTexture("planeInterior.png");

			rogerHeadTexture = LoadTexture("head.png");
			rogerTorsoTexture = LoadTexture("torso.png");
			rogerUpperArmTexture = LoadTexture("upperarm.png");
			rogerLowerArmTexture = LoadTexture("lowerarm.png");
			rogerUpperLegTexture = LoadTexture("upperleg.png");
			rogerLowerLegTexture = LoadTexture("lowerleg.png");

			planeTexture = LoadTexture("plane_at_scale.png");
			henchmanTexture = LoadTexture("enemy_basic.png");

			airLoopSound = LoadSound("sounds/air_loop.wav");
			groundHitSound = LoadSound("sounds/ground_hit.wav");
			gunshotSound = LoadSound("sounds/pistol_shot.wav");
			gunshotHitSound = LoadSound("sounds/gun_hit.wav");

			gbShader = LoadShader("base.vs", "gunbarrel_transparent.fs");
			slShader = LoadShader("base.vs", "spotlight.fs"); // spotlight shader

            gbBackgroundShader = LoadShader("base.vs", "gunbarrel.fs");
			
            
			gbTexLoc = GetShaderLocation(gbShader, "tex");
            gbBackgroundTexLoc = GetShaderLocation(gbBackgroundShader, "tex");
			slTexLoc = GetShaderLocation(slShader, "tex");

            gbBackgroundTimerLoc = GetShaderLocation(gbBackgroundShader, "timer");
			gbTimerLoc = GetShaderLocation(gbShader, "timer");
			gbCircLoc = GetShaderLocation(gbShader, "circCent");
            gbBackgroundCircLoc = GetShaderLocation(gbBackgroundShader, "circCent");

			slTimerLoc = GetShaderLocation(slShader, "timer");
			slCircLoc = GetShaderLocation(slShader, "circCent");
            SetShaderValueTexture(gbBackgroundShader, gbBackgroundTexLoc, gunbarrelBGTexture);
			SetShaderValueTexture(gbShader, gbTexLoc, gunbarrelTexture);
			SetShaderValueTexture(slShader, slTexLoc, rogerTexture);

        }

		
	}

	class GameStoredState
	{

		public float gameTimer = 0.0f;
		public GameState gameState = GameState.GUNBARREL_SCREEN;
		int planeInteriorState = 0;
		int skydivingState = 0;
		float persistentDirection = 0.0f;


	}

	class GunbarrelScene
	{
		int maxDots = 6;
		GunbarrelDot[] m_Dots;

		int dotCounter = 0;
		GunbarrelDot dotStart;
		GunbarrelDot nextDot;
		float dotTimeout = 0.7f;
		float dotSpeed = 350.0f;
		float dotRad = 40.0f; // 40

		bool dotStopped = false;
		float dotGrowthTimerMax = 0.5f;
		float dotGrowthTimer = 0.0f;

        float revealTimer = 0.0f;
        float revealTimerMax = 1.5f; // btw we're gonna start to need functions that are less linear


		float circTimer = 0.0f;
        float fasterCircTimer = 0.0f;
		float planeTimer = 0.0f;

		Vector2 rogerPosition; // much of this should be melded into a single player class/object/entity
		Vector2 rogerDirection;
		RogerSpriteSheet rogerSpriteSheet;
		float persistentDirection = 0.0f;

        bool holstering = false;

        bool gunHolstered = true; // could get the right effect by pulling out the gun to another layer and having it have its own sprite sheet, possibly

		float screenWidth;

        bool firing = false;
        bool fired = false;

        float turningAcceleration = 0.025f;
        float turningSpeed = 1.0f;
        float turningTimer = 0.0f;
        float turningDuration = 0.25f;
        float turningSpeedLimit = 0.0f;

        float rogerSpeedBase = 120.0f;

        float firingTimer = 0.0f;
        float aimingTimer = 0.0f;
        float aimToFireDuration = 0.5f;
        float holsteringTimer = 0.0f;
        float holsteringDuration = 0.5f;
        float timeBetweenShots = 0.1f;
        float interShotTimer = 0.0f;
        float interShotCooldown = 1.0f;
        float revealTimerInterp = 0.0f;

        float rogerVelocityX = 0.0f;
        float rogerAccelerationX = 0.0f;
        ParticleSystem[] ParticleSystems = null; // why not a list?
        
        int maxParticleSystems = 16;
        float particleTimer = 0.0f; // having only one timer is an issue
        // probably think about a state machine here, to handle multiple shots in a row etc
        

		
		Vector2 circLoc;

		public this(int _maxDots, GameResources gameResources)
		{
			InitScene(_maxDots, gameResources);
		}

		public ~this()
		{
			for (int i = 0; i < maxDots; i++)
			{
				delete m_Dots[i].Position;
				delete m_Dots[i];
			}
			delete rogerSpriteSheet;
			delete m_Dots;
            for (int i = 0; i < maxParticleSystems; i++)
            {
                delete ParticleSystems[i];
            }
            
            delete ParticleSystems;

		}

        public void AddParticleSystem(Vector2 pos, int waves, int particlesPerWave, float totalDuration, float emissionSpeed, float initialSpeedBase, float randomScale, int32 randomBound, Color baseColor, Color endColor, float initialDelay)
		{
            

            for (int i = 0; i < maxParticleSystems; i++)
            {
                if ((ParticleSystems[i] != null && !ParticleSystems[i].IsActive)) 
                {
                    delete ParticleSystems[i]; // we will remove this step soon
                    ParticleSystem psToAdd = new ParticleSystem(pos, waves, particlesPerWave, totalDuration, emissionSpeed, initialSpeedBase, randomScale, randomBound, baseColor, endColor, initialDelay);
                    ParticleSystems[i] = psToAdd;
                    break;
                }
                else if (ParticleSystems[i] == null)
                {
                    ParticleSystem psToAdd = new ParticleSystem(pos, waves, particlesPerWave, totalDuration, emissionSpeed, initialSpeedBase, randomScale, randomBound, baseColor, endColor, initialDelay);
                    ParticleSystems[i] = psToAdd;
                    break;
                }
                                
            }
                                                            
			
		}



		public void InitScene(int _maxDots, GameResources gameResources, float _screenWidth = 1920.0f)
		{
			screenWidth = _screenWidth;
			maxDots = _maxDots;
			m_Dots = new GunbarrelDot[maxDots];
			for (int i = 0; i < maxDots; i++)
			{
				m_Dots[i] = new GunbarrelDot(Vector2(i*(screenWidth - 100.0f)/maxDots, 520.0f), 0.0f, false);
			}
			
			dotGrowthTimerMax = 0.5f;
			dotStart = m_Dots[0];
			nextDot = m_Dots[0];
			rogerSpriteSheet = new RogerSpriteSheet(RogerAnimationState.STATIONARY, 0.0f, 0.125f, 128.0f, 128.0f);

			circLoc = *m_Dots[maxDots - 1].Position;
            
			rogerPosition = Vector2(circLoc.x, circLoc.y);
			rogerDirection = Vector2(0.0f, 0.0f);
            dotCounter = 0;
            circTimer = 0.0f;
            fasterCircTimer = 0.0f;
			// SetShaderValueTexture(gbShader, gbTexLoc, gameResources.gunbarrelTexture);
			// SetShaderValueTexture(slShader, slTexLoc, gameResources.rogerTexture);
			// SetShaderValue(gbShader, gbCircLoc, (void*)&circLoc, ShaderUniformDataType.SHADER_UNIFORM_VEC2);
			// SetShaderValue(gbShader, gbTimerLoc, (void*)&circTimer, ShaderUniformDataType.SHADER_UNIFORM_FLOAT);
			// SetShaderValue(slShader, slCircLoc, (void*)&circLoc, ShaderUniformDataType.SHADER_UNIFORM_VEC2);
			dotStopped = false;
            dotRad = 80.0f;//40.0f;

            revealTimer = 0.0f;
            revealTimerMax = 0.7f;
            revealTimerInterp = 0.0f;

            gunHolstered = true;

            
            
            ParticleSystems = new ParticleSystem[maxParticleSystems];

            


			SetShaderValue(gameResources.gbShader, gameResources.gbCircLoc, (void*)&circLoc, ShaderUniformDataType.SHADER_UNIFORM_VEC2);
            SetShaderValue(gameResources.gbBackgroundShader, gameResources.gbBackgroundCircLoc, (void*)&circLoc, ShaderUniformDataType.SHADER_UNIFORM_VEC2);
			SetShaderValue(gameResources.gbShader, gameResources.gbTimerLoc, (void*)&circTimer, ShaderUniformDataType.SHADER_UNIFORM_FLOAT);
            SetShaderValue(gameResources.gbBackgroundShader, gameResources.gbBackgroundTimerLoc, (void*)&circTimer, ShaderUniformDataType.SHADER_UNIFORM_FLOAT);
			SetShaderValue(gameResources.slShader, gameResources.slCircLoc, (void*)&circLoc, ShaderUniformDataType.SHADER_UNIFORM_VEC2);
		}

		public void ResetScene(GameResources gameResources)
		{
			for (int i = 0; i < maxDots; i++)
			{
				delete m_Dots[i].Position;
				delete m_Dots[i];
			}

			for (int i = 0; i < maxDots; i++)
			{
				m_Dots[i] = new GunbarrelDot(Vector2(i*(screenWidth - 100.0f)/maxDots, 520.0f), 0.0f, false);
			}
			dotStart = m_Dots[0];
			nextDot = m_Dots[0];
			circLoc = *m_Dots[maxDots - 1].Position;
			rogerPosition = Vector2(circLoc.x, circLoc.y);
			rogerDirection = Vector2(0.0f, 0.0f);
            persistentDirection = 0.0f;
            rogerVelocityX = 0.0f;
			dotStopped = false;
            circTimer = 0.0f;
            fasterCircTimer = 0.0f;
            dotGrowthTimer = 0.0f;
            dotGrowthTimerMax = 0.8f;
            dotCounter = 0;
            dotRad = 80.0f;//40.0f;
            gunHolstered = true;
            turningDuration = 0.25f;

            rogerSpriteSheet.Reset();

            revealTimer = 0.0f;
            revealTimerMax = 0.7f;
            
            revealTimerInterp = 0.0f;

            SetShaderValue(gameResources.gbShader, gameResources.gbCircLoc, (void*)&circLoc, ShaderUniformDataType.SHADER_UNIFORM_VEC2);
			SetShaderValue(gameResources.gbShader, gameResources.gbTimerLoc, (void*)&circTimer, ShaderUniformDataType.SHADER_UNIFORM_FLOAT);
            SetShaderValue(gameResources.gbBackgroundShader, gameResources.gbBackgroundCircLoc, (void*)&circLoc, ShaderUniformDataType.SHADER_UNIFORM_VEC2);
			SetShaderValue(gameResources.gbBackgroundShader, gameResources.gbBackgroundTimerLoc, (void*)&circTimer, ShaderUniformDataType.SHADER_UNIFORM_FLOAT);
			SetShaderValue(gameResources.slShader, gameResources.slCircLoc, (void*)&circLoc, ShaderUniformDataType.SHADER_UNIFORM_VEC2);
			
		}

		

		public void Update(float _dt)
		{
            //float dt = _dt / 5.0f; // for slowmo
            float dt = _dt;

            // let's do a system where
            // when you stop and aren't on a 'stop' frame,
            // it finds the nearest one

            float prevDirectionX = persistentDirection;
			rogerDirection.x = 0.0f;
			rogerDirection.y = 0.0f;
            

            fired = false;
            if (IsMouseButtonPressed(MouseButton.MOUSE_LEFT_BUTTON))
            {
                if (!gunHolstered)
                {
                    // play firing animation
                    fired = true;
                }
            }

            holstering = false;

            if (IsMouseButtonDown(MouseButton.MOUSE_RIGHT_BUTTON))
            {
                holstering = true;
                // if (gunHolstered)
                // {
                //     // play firing animation
                //     holstering = true;
                // }
            }

            // should probably move to a lerped system
            // so we can go back and forth between animation states
            // if it don't loop, then the update
            // is a lerp?

            if (holstering)
            {
                if (rogerSpriteSheet.State != RogerAnimationState.UNHOLSTERING)
                {
                    rogerSpriteSheet.SetState(RogerAnimationState.UNHOLSTERING, false);
                }
                holsteringTimer += dt;
                holsteringTimer = Math.Min(holsteringTimer, holsteringDuration);

                if (holsteringTimer >= holsteringDuration/2.0f)
                {
                    gunHolstered = false;
                }
                // if (holsteringTimer >= holsteringDuration)
                // {
                //     gunHolstered = false;
                //     holstering = false;
                //     rogerSpriteSheet.SetState(RogerAnimationState.UNHOLSTERING, false);
                // }
                String holsterFrameText = scope  $"holster time is {holsteringTimer}";
                //DrawText(holsterFrameText, 10, 10, 12, Color.WHITE);
            }
            else
            {
                
                holsteringTimer -= dt;
                holsteringTimer = Math.Max(holsteringTimer, 0.0f);
                
                if (holsteringTimer < holsteringDuration/2.0f)
                {
                    gunHolstered = true;
                }

                // TODO (Cooper) : buffering inputs is going to feel better here
                // but I think we only need ot buffer them
                // if they can't occur
                
            }

            
            
            
            if (fired)
            {
                Vector2 smokePos = Vector2(rogerPosition.x-4.0f, rogerPosition.y-30.0f);
                // need to add an ability to  delay in
                AddParticleSystem(smokePos, 1, 25, 0.125f, 0.25f, 1.0f, 1.0f, 100, Color(255,74,0,255), Color(255,180,0,50), 0.0f);
                AddParticleSystem(smokePos, 1, 50, 0.25f, 0.25f, 25.0f, 1.0f, 100, Color(50,50,50,200), Color(150,150,150,0), 0.1f);
                // = false;
            }


            // else if (rogerSpriteSheet.State == RogerAnimationState.SHOOTING)
            // {
            //     // this is going to get out of hand quickly,
            //     // need to think more about the state machine
            //     // or whatever
            //     rogerSpriteSheet.SetState(RogerAnimationState.STATIONARY);
            // }

            if (!firing && firingTimer > 0.0f) // this is actually the just finished firing, 'between shots' phase
            {
                interShotTimer += dt;

                if (interShotTimer >= interShotCooldown)
                {
                    firingTimer = 0.0f;
                }
            }

			if (IsKeyDown(KeyboardKey.KEY_A) && !holstering)
			{
				rogerDirection.x = -1.0f;
				persistentDirection = rogerDirection.x;
			}
			if (IsKeyDown(KeyboardKey.KEY_D) && !holstering)
			{
				rogerDirection.x = 1.0f;
				persistentDirection = rogerDirection.x;
			}
			

            

			
			if (rogerDirection.x != 0.0f && holsteringTimer == 0.0f)
			{
                if (prevDirectionX != 0.0f && persistentDirection != prevDirectionX && rogerSpriteSheet.State != RogerAnimationState.TURNING)
                {
                    rogerSpriteSheet.SetState(RogerAnimationState.TURNING, false, true);
                }
                else if (rogerSpriteSheet.State != RogerAnimationState.WALKING && (rogerSpriteSheet.State != RogerAnimationState.TURNING || turningTimer >= turningDuration))
                {
                    rogerSpriteSheet.SetState(RogerAnimationState.WALKING);
                } // also think about a transition state when changing direction!
                
                
				//TextureDrawing.UpdateSpriteSheet(ref rogerSpriteSheet, dt*1.5f);
			}
            else if ((rogerSpriteSheet.State == RogerAnimationState.WALKING && rogerVelocityX == 0.0f) ||
                     (rogerSpriteSheet.State == RogerAnimationState.UNHOLSTERING && !holstering && holsteringTimer == 0.0f ||
                         rogerSpriteSheet.State == RogerAnimationState.TURNING && turningTimer >= turningDuration)
                )
            {
                rogerSpriteSheet.SetState(RogerAnimationState.STATIONARY);
            }

            if (rogerSpriteSheet.State == RogerAnimationState.TURNING)
            {
                String holsterFrameText = scope  $"holster time is {holsteringTimer}";
                DrawText(holsterFrameText, 10, 10, 12, Color.WHITE);
                
                turningTimer += (dt * turningSpeed*0.5f);
                turningTimer = Math.Min(turningDuration, turningTimer);
                rogerSpriteSheet.AnimLerp = turningTimer / turningDuration;
                if (rogerDirection.x != 0.0f)
                {
                    
                    //turningSpeed += (turningAcceleration*0.1f);
                    //turningSpeedLimit += turningAcceleration*50.0f;
                    //turningSpeedLimit = rogerSpeedBase;
                    //turningSpeedLimit = Math.Min(turningSpeedLimit, rogerSpeedBase);
                }
            }
            else
            {
                
                turningTimer = 0;
                turningSpeed = 1.0f;
                turningSpeedLimit = rogerSpeedBase/4.0f;
                
                rogerSpriteSheet.AnimLerp = holsteringTimer / holsteringDuration;
            }

            float rogerSpeed = 360.0f;//rogerSpeedBase;
            if (rogerSpriteSheet.State == RogerAnimationState.TURNING)
            {
                rogerSpeed = turningSpeedLimit; // we should increase this limit over time
                // or introduce momentum/velocity etc, and also speed up the animation accordingly
                // if you're attempting to keep moving

                
            }
            
            float forceX = rogerDirection.x * dt * rogerSpeed;
            float rogerFrictionX = 0.0f;


            if (rogerDirection.x == 0.0f && (rogerVelocityX * rogerVelocityX) > 10.0f)
            {
                rogerFrictionX = -1.0f*rogerVelocityX*3.0f*dt;
                if ((rogerVelocityX * rogerVelocityX) < 15.0f && (rogerSpriteSheet.CurrentFrameSection == rogerSpriteSheet.WalkingFrameEnd-1))
                {
                    rogerVelocityX = 0.0f;
                }
            }
            
            
            rogerVelocityX += (forceX + rogerFrictionX);
			float currentSpeed = Math.Abs(rogerVelocityX);
			float maxSpeed = 100.0f;
			if (currentSpeed > maxSpeed)
			{
				rogerVelocityX = Math.Sign(rogerVelocityX) * maxSpeed;
			}
            float stopDelta = 20.0f;
			if (Math.Abs(rogerVelocityX) < stopDelta && rogerDirection.x == 0.0f)
			{
				// we could actually use the animation frame to set the stop frame, so to speak, which might look better.
				rogerVelocityX = 0.0f;
			}
            
            
			rogerPosition.x += rogerVelocityX * dt ;

            
            // rather than decreasing the frame time, we should just INCREASE the input time

			float rogerAnimSpeedModifier = 1.0f;
			float animSpeed = Math.Abs(rogerVelocityX);
			float animMax = 10000.0f; // or whatever it is
			animSpeed = Math.Min(animSpeed, animMax);
			float animSpeedNormal = animSpeed / animMax;
			float speedModifier = 1.0f;
			if (rogerSpriteSheet.State == RogerAnimationState.WALKING && rogerDirection.x == 0.0f)
			{
				// issue here is that we're sort of fixing 2 different states and one of them is velocity dependent
				speedModifier = 2.2f;
				rogerSpriteSheet.Update(dt*rogerAnimSpeedModifier*speedModifier);
				// honestly a smarter thing to do here is to continue to play the animation until he ACTUALLY should stop,
				// which would be a little animation driven but should work well.
				// see above
			}
			else
			{

				rogerSpriteSheet.Update(dt*rogerAnimSpeedModifier + speedModifier*animSpeedNormal);
			}
			
            //rogerSpriteSheet.Update(dt*rogerAnimSpeedModifier + speedModifier*animSpeedNormal);
            // else if (!rogerSpriteSheet.CurrentFrame = 4)
            // {
            //     TextureDrawing.UpdateSpriteSheet(ref rogerSpriteSheet, dt*1.5f);
            // }
			//dotStart.Position.x += dt * dotSpeed;
			if (dotStart.Position.x < m_Dots[maxDots - 1].Position.x && !dotStopped)
			{
				dotStart.Position.x += dt * dotSpeed;
				if (Matrix2.Vector2Distance(*(nextDot.Position), *(dotStart.Position)) < 3.0f && !nextDot.Active)
				{
					
					m_Dots[dotCounter].Active = true;
					if (dotCounter < maxDots - 1)
					{
						dotCounter += 1;
						nextDot = m_Dots[dotCounter];
					}
				}

				for (int i = 0; i < maxDots; i++)
				{
					if (m_Dots[i].Active)
					{
						m_Dots[i].Timer += dt;
						if (m_Dots[i].Timer >= dotTimeout)
						{
							m_Dots[i].Active = false;
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

                // I think we want to start incrementing our reveal timer later than the other one
                // since the texure is smaller

                if (revealTimer < revealTimerMax)
                {
                    revealTimer += dt;
                    revealTimerInterp = Math.Min(revealTimer / revealTimerMax, 1.0f);
                }
                
			}
            

            for (int i = 0; i < maxParticleSystems; i++)
            {
                if (ParticleSystems[i] != null) // let's make this not possible
                {
                    ParticleSystems[i].UpdateParticleSystem(dt);
                }
                
            }
            
		}

		public void Render(GameResources gameResources)
        {
            if (IsKeyPressed(KeyboardKey.KEY_F11))
			{
				ResetScene(gameResources);
			}
            if (IsKeyPressed(KeyboardKey.KEY_F10))
			{
                gameResources.Reload();
			}

            BeginDrawing();
            ClearBackground(.(0,0,0,255));
            
            if (!dotStopped)
            {
                for (var dot in m_Dots)
                {
                    //DrawCircle((int32)dot.Position.x, (int32)dot.Position.y, dotRad, Color.WHITE);
                    if (dot.Active)
                    {
                        DrawCircle((int32)dot.Position.x, (int32)dot.Position.y, dotRad, Color.WHITE);
                    }
                }
            }

			if (dotStopped)
			{
                // NOTE (Cooper) : two ways of handling this
                // either we figure  out how to do 2 shaders at once
                // or we switch out one large texture for the split version
                fasterCircTimer = circTimer;
                SetShaderValue(gameResources.gbBackgroundShader, gameResources.gbBackgroundTimerLoc, (void*)&circTimer, ShaderUniformDataType.SHADER_UNIFORM_FLOAT);
                BeginShaderMode(gameResources.gbBackgroundShader);                
                DrawTextureEx(gameResources.gunbarrelBGTexture, Vector2(0.0f, 0.0f), 0.0f, 10.0f, Color.WHITE);
                EndShaderMode();
                
				BeginShaderMode(gameResources.gbShader);
				SetShaderValue(gameResources.gbShader, gameResources.gbTimerLoc, (void*)&circTimer, ShaderUniformDataType.SHADER_UNIFORM_FLOAT);
                
				DrawTextureEx(gameResources.gunbarrelTexture, Vector2((int)(-560.0f + rogerPosition.x), 200.0f), 0.0f, 10.0f, Color.WHITE);
				EndShaderMode();
                
                // rather than a straight circle, what we actually want here is to draw
                // the Roger/Sean/Daniel/Tim/George/Pierce sprite with a circle shader on it. 
                //DrawCircle((int32)dotStart.Position.x, (int32)dotStart.Position.y, dotRad + dotGrowthTimer*200.0f, Color.WHITE);
				DrawCircle((int32)rogerPosition.x, (int32)rogerPosition.y, dotRad + dotGrowthTimer*140.0f, Color.WHITE);
								

                

                SetShaderValue(gameResources.slShader, gameResources.slTimerLoc, (void*)&revealTimerInterp, ShaderUniformDataType.SHADER_UNIFORM_FLOAT);
				BeginShaderMode(gameResources.slShader);
				//float spotlightRad = dotRad + dotGrowthTimer*200.0f;
				
				
				//DrawTextureEx(rogerTexture, Vector2(50.0f, 50.0f), 0.0f, 10.0f, Color.WHITE);
				// DrawTextureCentered(rogerTexture, rogerPosition.x - 10.0f, rogerPosition.y - 50.0f, 0.0f, 2.0f, Color.WHITE);
								
				
				// check for roger's direction here

                // TODO (Cooper):
                // the fact that we're drawing separate sprites
                // is actually making this harder, since the scales are different
                // so instead, I think what we SHOULD do is render everything that should be revealed
                // to a texture, and then
                // 'reveal' THAT
				// TextureDrawing.DrawPartialTextureCentered(gameResources.rogerTexture, rogerSpriteSheet.CurrentRect, rogerPosition.x - 16.0f, rogerPosition.y, rogerSpriteSheet.FrameWidth, rogerSpriteSheet.FrameHeight, 0.0f, 2.0f, Color.WHITE);

                int debugText = 0;
				if (rogerDirection.x < 0.0f)
				{
                                        
					TextureDrawing.DrawPartialTextureCentered(gameResources.rogerTexture, rogerSpriteSheet.CurrentRect, rogerPosition.x - 16.0f, rogerPosition.y, rogerSpriteSheet.FrameWidth, rogerSpriteSheet.FrameHeight, 0.0f, 2.0f, Color.WHITE);
				}
				else if ((rogerDirection.x > 0.0f || persistentDirection > 0.0f) || (rogerDirection.x < 0.0f && rogerSpriteSheet.State == RogerAnimationState.TURNING))
				{

                    debugText = 1;
					TextureDrawing.DrawPartialTextureCenteredFlipped(gameResources.rogerTexture, rogerSpriteSheet.CurrentRect, rogerPosition.x , rogerPosition.y, rogerSpriteSheet.FrameWidth, rogerSpriteSheet.FrameHeight, 0.0f, 2.0f, Color.WHITE);
				}
				else
				{
                    debugText = 2;
					TextureDrawing.DrawPartialTextureCentered(gameResources.rogerTexture, rogerSpriteSheet.CurrentRect, rogerPosition.x - 16.0f, rogerPosition.y, rogerSpriteSheet.FrameWidth, rogerSpriteSheet.FrameHeight, 0.0f, 2.0f, Color.WHITE);
				}
                EndShaderMode();

                if (debugText == 0)
                {
                    String currentFrameText = scope $"drawing normal anim";                
                    DrawText(currentFrameText, 10, 10, 16, Color.RED);
                }
                else if (debugText == 1)
                {
                    String currentFrameText = scope $"drawing flipped anim";                
                    DrawText(currentFrameText, 10, 10, 16, Color.RED);
                }
                else if (debugText == 2)
                {
                    String currentFrameText = scope $"drawing default anim";                
                    DrawText(currentFrameText, 10, 10, 16, Color.RED);
                }

				String rogerCurrent = scope $"roger current pos is {rogerPosition.x} with velocity {rogerVelocityX}";
				DrawText(rogerCurrent, 10,30,16, Color.RED);

                
				String currentFrameText = scope $"current frame is {rogerSpriteSheet.CurrentFrameSection} against {rogerSpriteSheet.WalkingFrameEnd}";
				DrawText(currentFrameText, 10, 60, 14, Color.RED);

                // String animFrameText = scope  $"anim frame is {rogerSpriteSheet.CurrentFrame}";
            

                // DrawText(animFrameText, 10, 10, 12, Color.WHITE);
			}
			else
			{
				DrawCircle((int32)dotStart.Position.x, (int32)dotStart.Position.y, dotRad, Color.WHITE);
			}

            for (int i = 0; i < maxParticleSystems; i++)
            {
                if (ParticleSystems[i] != null)
                {
                    ParticleSystems[i].DrawParticleSystem();
                }
                
            }
            EndDrawing();
		}

	}

	// class SkeletalEditor
	// {

	// 	public void Update() {

	// 	       Vector2 toAdd = Vector2(0.0f, 0.0f);

	// 		if (IsKeyPressed(KeyboardKey.KEY_F1))
	// 		{
	// 			skeletalEditorState--;
	// 			skeletalEditorState = Math.Max(0, skeletalEditorState);
	// 		}
	// 		if (IsKeyPressed(KeyboardKey.KEY_F2))
	// 		{
	// 			skeletalEditorState++;
	// 			skeletalEditorState = Math.Min(skeletalEditorState, SkeletalEditorState.NUM_STATES-1);
	// 		}
	// 		if (IsKeyPressed(KeyboardKey.KEY_F5))
	// 		{
	// 			needSave = true;
	// 		}
	// 		if (IsKeyPressed(KeyboardKey.KEY_F6))
	// 		{
	// 			needLoad = true;
	// 		}
	// 		if (IsKeyDown(KeyboardKey.KEY_LEFT))
	// 		{
	// 			toAdd.x = -1.0f;
	// 		}
	// 		if (IsKeyDown(KeyboardKey.KEY_RIGHT))
	// 		{
	// 			toAdd.x = 1.0f;
	// 		}
	// 		if (IsKeyDown(KeyboardKey.KEY_UP))
	// 		{
	// 			toAdd.y = -1.0f;
	// 		}
	// 		if (IsKeyDown(KeyboardKey.KEY_DOWN))
	// 		{
	// 			toAdd.y = 1.0f;
	// 		}
	// 		toAdd = Matrix2.Vector2Scale(toAdd, dt * 40.0f);
	// 		switch (skeletalEditorState)
	// 		{
	// 		case SkeletalEditorState.WHOLE_BODY:
	// 			rogerPosition = Matrix2.Vector2Add(rogerPosition, toAdd);
	// 			break;
	// 		case SkeletalEditorState.HEAD:
	// 			rogerHeadPosition = Matrix2.Vector2Add(rogerHeadPosition, toAdd);
	// 			break;
	// 		case SkeletalEditorState.TORSO:
	// 			rogerTorsoPosition = Matrix2.Vector2Add(rogerTorsoPosition, toAdd);
	// 			break;
	// 		case SkeletalEditorState.UPPER_ARM:
	// 			rogerUpperArmPosition = Matrix2.Vector2Add(rogerUpperArmPosition, toAdd);
	// 			break;
	// 		case SkeletalEditorState.LOWER_ARM:
	// 			rogerLowerArmPosition = Matrix2.Vector2Add(rogerLowerArmPosition, toAdd);
	// 			break;
	// 		case SkeletalEditorState.UPPER_LEG:
	// 			rogerUpperLegPosition = Matrix2.Vector2Add(rogerUpperLegPosition, toAdd);
	// 			break;
	// 		case SkeletalEditorState.LOWER_LEG:
	// 			rogerLowerLegPosition = Matrix2.Vector2Add(rogerLowerLegPosition, toAdd);
	// 			break;
	// 		default:
	// 			break;
	// 		}
	// 		if (needSave)
	// 		{
	// 			System.IO.BufferedFileStream bufferedStream = new System.IO.BufferedFileStream();
	// 			bufferedStream.Create("skeleton.bin");
	// 			Skeleton skeleton = new Skeleton();
	// 			skeleton.Head = rogerHeadPosition;
	// 			skeleton.Torso = rogerTorsoPosition;
	// 			skeleton.UpperArm = rogerUpperArmPosition;
	// 			skeleton.LowerArm = rogerLowerArmPosition;
	// 			skeleton.UpperLeg = rogerUpperLegPosition;
	// 			skeleton.LowerLeg = rogerLowerLegPosition;

	// 			bufferedStream.Write(skeleton.Head);
	// 			bufferedStream.Write(skeleton.Torso);
	// 			bufferedStream.Write(skeleton.UpperArm);
	// 			bufferedStream.Write(skeleton.LowerArm);
	// 			bufferedStream.Write(skeleton.UpperLeg);
	// 			bufferedStream.Write(skeleton.LowerLeg);
	// 			bufferedStream.Close();
	// 			delete skeleton;
	// 			delete bufferedStream;
	// 			needSave = false;
	// 		}

	// 		if (needLoad)
	// 		{
	// 			System.IO.BufferedFileStream bufferedStream = new System.IO.BufferedFileStream();
	// 			bufferedStream.Open("skeleton.bin");
	// 			Skeleton skeleton = new Skeleton();


	// 			skeleton.Head = bufferedStream.Read<Vector2>();
	// 			skeleton.Torso = bufferedStream.Read<Vector2>();
	// 			skeleton.UpperArm = bufferedStream.Read<Vector2>();

	// 			skeleton.LowerArm = bufferedStream.Read<Vector2>();
	// 			skeleton.UpperLeg = bufferedStream.Read<Vector2>();
	// 			skeleton.LowerLeg = bufferedStream.Read<Vector2>();

	// 			bufferedStream.Close();

	// 			rogerHeadPosition = skeleton.Head ;
	// 			rogerTorsoPosition = skeleton.Torso;
	// 			rogerUpperArmPosition = skeleton.UpperArm;
	// 			rogerLowerArmPosition = skeleton.LowerArm;
	// 			rogerUpperLegPosition = skeleton.UpperLeg;
	// 			rogerLowerLegPosition = skeleton.LowerLeg;
	// 			delete skeleton;
	// 			delete bufferedStream;
	// 			needLoad = false;
	// 		}
	// 	}
	// }

	class SkyScene
	{
		Rectangle cloudRect;
		int maxClouds;
		int screenWidth;
		int screenHeight;
		int maxPlaneClouds;
		float[] planeCloudDistances;
		int[] planeCloudWidths;
		Vector2[] planeClouds;
		Vector2[] clouds;
		
		public this(GameResources gameResources, int _maxClouds, int _maxPlaneClouds, int _screenWidth, int _screenHeight)
		{
			maxClouds = _maxClouds;
			maxPlaneClouds = _maxPlaneClouds;
			cloudRect = Rectangle(0, 0, gameResources.cloudTexture.width, gameResources.cloudTexture.height);

			planeCloudDistances = new float[maxPlaneClouds];
			planeCloudWidths = new int[maxPlaneClouds];
			planeClouds = new Vector2[maxPlaneClouds];
			screenWidth = _screenWidth;
			screenHeight = _screenHeight;
			

			for (int i = 0; i < maxPlaneClouds; i++)
			{
				int32 randPos = GetRandomValue(0, (int32)screenWidth);
				int32 randHeight = GetRandomValue(0, (int32)screenHeight);
				float dist = ((float)(maxPlaneClouds - i) / (float)maxPlaneClouds) * 10.0f + 1.0f;
				planeCloudDistances[i] = dist;
				planeClouds[i] = Vector2(randPos, randHeight);
				planeCloudWidths[i] = GetRandomValue(30, 150);


			}

			clouds = new Vector2[maxClouds];

			
			
			

			for (int i = 0; i < maxClouds; i++)
			{
				int32 randPos = GetRandomValue(0, (int32)screenWidth);
				clouds[i] = Vector2(randPos, (int32)screenHeight * (i ) / ( maxClouds));
			}
		}
	}

	class PlaneInteriorScene
	{
		Person rogerInPlane = new Person(Vector2(100.0f, 400.0f), 100);
		float doorWidth = 30.0f;
		float doorHeight = 30.0f;
		Person doorInPlane = new Person(Vector2(935.0f - doorWidth, 304.0f - doorHeight) , 100);

		
	}



	
}
