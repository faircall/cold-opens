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

	public enum PauseState
        {
            Paused,
			Unpaused,
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
                
                // String currentFrameText = scope $"current frame is {CurrentFrameSection}";
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

		public RenderTexture2D renderTarget;

		public Texture2D henchmanTexture;

		public Sound airLoopSound;
		public Sound groundHitSound;
        public Sound gunbarrelGunshotSound;
		public Sound gunshotSound;
		public Sound gunshotHitSound;

		public Sound themeStrings;
		public Sound themeIntro;

		// why not include shaders here?

		public Shader gbShader;
        public Shader gbBackgroundShader;
		public Shader slShader;
		public Shader bloodShader;

        
		public int32 gbTexLoc;
        public int32 gbBackgroundTexLoc;
		public int32 slTexLoc;

        
		public int32 gbTimerLoc;
        public int32 gbBackgroundTimerLoc;
		public int32 gbCircLoc;        
		public int32 gbBackgroundCircLoc;

		public int32 slTimerLoc;
		public int32 slCircLoc;
		public int32 deathTimerLoc;

		public int screenWidth = 1280;
		public int screenHeight = 720;


        




		// SetShaderValueTexture(gbShader, gbTexLoc, gameResources.gunbarrelTexture);
		// SetShaderValueTexture(slShader, slTexLoc, gameResources.rogerTexture);
		// SetShaderValue(gbShader, gbCircLoc, (void*)&circLoc, ShaderUniformDataType.SHADER_UNIFORM_VEC2);
		// SetShaderValue(gbShader, gbTimerLoc, (void*)&circTimer, ShaderUniformDataType.SHADER_UNIFORM_FLOAT);
		// SetShaderValue(slShader, slCircLoc, (void*)&circLoc, ShaderUniformDataType.SHADER_UNIFORM_VEC2);

		public this(int screenWidth, int screenHeight)
		{

            Reload(screenWidth, screenHeight);
			
		}

		public ~this()
		{
		}

        public void Reload(int _screenWidth, int _screenHeight)
        {
			screenWidth = _screenWidth;
			screenHeight = _screenHeight;
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
			henchmanTexture = LoadTexture("enemySkydive.png");

			airLoopSound = LoadSound("sounds/air_loop.wav");
			groundHitSound = LoadSound("sounds/ground_hit.wav");
			gunshotSound = LoadSound("sounds/pistol_shot.wav");
			gunshotHitSound = LoadSound("sounds/gun_hit.wav");

			themeStrings = LoadSound("music/theme_strings_gap.ogg");
			themeIntro = LoadSound("music/theme_intro.ogg");
				//themeStrings.loopCount = 1;
			//themeStrings.

			gbShader = LoadShader("base.vs", "gunbarrel_transparent.fs");
			slShader = LoadShader("base.vs", "spotlight.fs"); // spotlight shader

            gbBackgroundShader = LoadShader("base.vs", "gunbarrel.fs");

			bloodShader = LoadShader("base.vs", "bloodScreen.fs");
			
            
			gbTexLoc = GetShaderLocation(gbShader, "tex");
            gbBackgroundTexLoc = GetShaderLocation(gbBackgroundShader, "tex");
			slTexLoc = GetShaderLocation(slShader, "tex");

            gbBackgroundTimerLoc = GetShaderLocation(gbBackgroundShader, "timer");
			gbTimerLoc = GetShaderLocation(gbShader, "timer");
			gbCircLoc = GetShaderLocation(gbShader, "circCent");
            gbBackgroundCircLoc = GetShaderLocation(gbBackgroundShader, "circCent");

			slTimerLoc = GetShaderLocation(slShader, "timer");
			slCircLoc = GetShaderLocation(slShader, "circCent");
			deathTimerLoc = GetShaderLocation(bloodShader, "deathTimer");
			
            SetShaderValueTexture(gbBackgroundShader, gbBackgroundTexLoc, gunbarrelBGTexture);
			SetShaderValueTexture(gbShader, gbTexLoc, gunbarrelTexture);
			SetShaderValueTexture(slShader, slTexLoc, rogerTexture);

			renderTarget = LoadRenderTexture((int32)screenWidth, (int32)screenHeight);


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

	class PlaneScene
	{
		Vector2[] m_planeClouds;
		float[] m_planeCloudDistances;
		Vector2 m_planePos;
		int[] m_planeCloudWidths;
		float m_screenWidth;
		Rectangle m_cloudRect;// = Rectangle(0, 0, cloudTexture.width, cloudTexture.height);
		float m_planeTimer;

		public this(GameResources gameResources, int32 screenWidth, int32 screenHeight)
		{
			Reload(gameResources, screenWidth, screenHeight);
		}

		public ~this()
		{
			delete m_planeClouds;
			delete m_planeCloudDistances;
			delete m_planeCloudWidths;
		}

		public void Reload(GameResources gameResources, int32 screenWidth, int32 screenHeight)
		{
			m_planePos = Vector2((float)screenWidth, 50.0f);
			int maxClouds = 64;
			m_planeClouds = new Vector2[maxClouds];
			m_planeCloudDistances = new float[maxClouds];
			m_planeCloudWidths = new int[maxClouds];
			m_cloudRect = Rectangle(0, 0, gameResources.cloudTexture.width, gameResources.cloudTexture.height);

			for (int i = 0; i < maxClouds; i++)
			{
			 	int32 randPos = GetRandomValue(0, screenWidth);
			 	int32 randHeight = GetRandomValue(0, screenHeight);
			 	float dist = ((float)(maxClouds - i) / (float)maxClouds) * 10.0f + 1.0f;
			 	m_planeCloudDistances[i] = dist;
			 	m_planeClouds[i] = Vector2(randPos, randHeight);
			 	m_planeCloudWidths[i] = GetRandomValue(30, 150);
			}

		}	

		public bool Update(float dt, float screenWidth)
		{
			bool switchScene = false;
			m_planeTimer += dt;

			UpdateClouds(dt, screenWidth);
			
			
			float planeSpeed = 130.0f;
			m_planePos.x -= planeSpeed * dt;

			if (m_planePos.x < 0.0f || IsKeyPressed(KeyboardKey.KEY_SPACE))
			{
				switchScene = true;
			}

			return switchScene;
		}

		public void UpdateClouds(float dt, float screenWidth)
		{
			for (int i = 0; i < m_planeClouds.Count; i++)
			{
				float cloudSpeed = 100.0f * 1.0f/m_planeCloudDistances[i];
				m_planeClouds[i].x += dt * cloudSpeed;
				if (m_planeClouds[i].x > screenWidth+50.0f)
				{
					m_planeClouds[i].x = -150.0f;
				}
			}
		}

		public void Render(GameResources gameResources)
		{
			BeginDrawing();
			ClearBackground(.(50, 120, 250, 255));
			float planeLoc = 5.0f;
			Color slightlyTransparent = Color(255, 255, 255, 180);
			for (int i = 0; i < m_planeClouds.Count; i++)
			{
				Vector2 cloud = m_planeClouds[i];
				if (m_planeCloudDistances[i] >= planeLoc)
				{
					float scaleToDraw = (1.0f/m_planeCloudDistances[i]) * 10.0f; // .01 to 1.0
					Rectangle dest = Rectangle((int)cloud.x, (int)cloud.y, m_planeCloudWidths[i]*scaleToDraw, gameResources.cloudTexture.height*scaleToDraw);
					DrawTexturePro(gameResources.cloudTexture, m_cloudRect, dest, Vector2(0.0f, 0.0f), 0.0f, Color.WHITE);
					//DrawTextureEx(cloudTexture, Matrix2.Vector2Subtract(cloud, cameraPosition), 0.0f, scaleToDraw, Color.WHITE);
				}
			}
			DrawTextureEx(gameResources.planeTexture, m_planePos, 0.0f, 1.0f, Color.RAYWHITE);
			for (int i = 0; i < m_planeClouds.Count; i++)
			{
				Vector2 cloud = m_planeClouds[i];
				if (m_planeCloudDistances[i] < planeLoc)
				{
					float scaleToDraw = (1.0f/m_planeCloudDistances[i]) * 10.0f; // .01 to 1.0
					Rectangle dest = Rectangle((int)cloud.x, (int)cloud.y, m_planeCloudWidths[i]*scaleToDraw, gameResources.cloudTexture.height*scaleToDraw);
					DrawTexturePro(gameResources.cloudTexture, m_cloudRect, dest, Vector2(0.0f, 0.0f), 0.0f,slightlyTransparent);
					//DrawTextureEx(cloudTexture, Matrix2.Vector2Subtract(cloud, cameraPosition), 0.0f, scaleToDraw, Color.WHITE);
				}
			}
			EndDrawing();
		}

	}

	class GunbarrelScene
	{
		int maxDots = 6;
		GunbarrelDot[] m_Dots;

		int dotCounter = 0;
		GunbarrelDot dotStart;
		GunbarrelDot nextDot;
		float dotTimeout = 0.7f;
		float dotSpeed = 400.0f;
		float dotRad = 40.0f; // 40
		AudioManager m_audioManager;

		bool dotStopped = false;
		float dotGrowthTimerMax = 0.5f;
		float dotGrowthTimer = 0.0f;

        float revealTimer = 0.0f;
        float revealTimerMax = 1.5f; // btw we're gonna start to need functions that are less linear
		float revealTimerFinish = 3.0f;


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
        float turningSpeed = 3.0f;
        float turningTimer = 0.0f;
        float turningDuration = 0.125f;
        float turningSpeedLimit = 0.0f;

        float rogerSpeedBase = 1000.0f;

        float firingTimer = 0.0f;
        float aimingTimer = 0.0f;
        float aimToFireDuration = 0.5f;
        float holsteringTimer = 0.0f;
        float holsteringDuration = 0.35f;
        float timeBetweenShots = 0.1f;
        float interShotTimer = 0.0f;
        float interShotCooldown = 1.0f;
        float revealTimerInterp = 0.0f;

		int enemyHealth = 100;
		float enemyDeathTimer = 0.0f;

        float rogerVelocityX = 0.0f;
        float rogerAccelerationX = 0.0f;
        ParticleSystem[] ParticleSystems = null; // why not a list?

		bool playedIntro = false;
        
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
			delete m_audioManager;
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
			m_audioManager = new AudioManager();
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
            turningDuration = 0.125f;

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

		

		public GameState Update(float _dt, GameState gameState)
		{
			

			GameState result = gameState;
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
                // String holsterFrameText = scope  $"holster time is {holsteringTimer}";
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

				enemyHealth -= 100; // or whatever
				m_audioManager.SoundsToPlay.Add("gunshot");
                // = false;
            }

			if (enemyHealth <= 0)
			{

				enemyDeathTimer += dt;
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

            float rogerSpeed = 1000.0f;//rogerSpeedBase;
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
			float maxSpeed = 200.0f;
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
			float animMax = 15000.0f; // or whatever it is
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

				if (enemyDeathTimer >= 5.0f)
				{
					result = GameState.PLANE_SCREEN;
				}
                
			}
            

            for (int i = 0; i < maxParticleSystems; i++)
            {
                if (ParticleSystems[i] != null) // let's make this not possible
                {
                    ParticleSystems[i].UpdateParticleSystem(dt);
                }
                
            }

			return result;
            
		}

		public void Render(GameResources gameResources)
        {
			// audio stuff here...incredibly ugly atm
			if (!playedIntro)
			{
				if (!IsSoundPlaying(gameResources.themeIntro))
				{
					PlaySound(gameResources.themeIntro);
				}				
				playedIntro = true;
			} 
			else 
			{
				if (!IsSoundPlaying(gameResources.themeIntro))
				{
					if (!IsSoundPlaying(gameResources.themeStrings))
					{
						PlaySound(gameResources.themeStrings);
					}
				}				
			}
			

			

			for (var sound in m_audioManager.SoundsToPlay)
			{
				if (sound == "gunshot") 
				{
					PlaySound(gameResources.gunshotSound);
					m_audioManager.SoundsToPlay.Remove(sound);
				}
			}

			

			//UpdateMusicStream(gameResources.themeStrings);

            if (IsKeyPressed(KeyboardKey.KEY_F11))
			{
				ResetScene(gameResources);
			}
            if (IsKeyPressed(KeyboardKey.KEY_F10))
			{
                gameResources.Reload(gameResources.screenWidth, gameResources.screenHeight);
			}

           
            
            if (!dotStopped)
            {
				BeginDrawing();
				ClearBackground(.(0,0,0,255));
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
				BeginTextureMode(gameResources.renderTarget);

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
				EndTextureMode();

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

				//Color bloodScreenColor = Color(200,0,0,90);
				float screenDuration = 8.0f;
				float lerpedBloodScreen = Math.Min((enemyDeathTimer / (screenDuration/2.0f)), 2.0f);
				//int32 bloodScreenHeight = (int32)(lerpedBloodScreen * GetScreenHeight());
				BeginDrawing();
				ClearBackground(.(0,0,0,255));
				BeginShaderMode(gameResources.bloodShader);
				SetShaderValue(gameResources.bloodShader, gameResources.deathTimerLoc, (void*)&lerpedBloodScreen, ShaderUniformDataType.SHADER_UNIFORM_FLOAT);
				DrawTextureRec(gameResources.renderTarget.texture, Rectangle(0.0f, 0.0f, gameResources.screenWidth, -1.0f*gameResources.screenHeight), Vector2(0.0f, 0.0f), Color(255,255,255,255));
				EndShaderMode();
				
				//DrawRectangle(0, 0, (int32)screenWidth, bloodScreenHeight, bloodScreenColor);
				// there's a simple way to achieve the effect I'm after using an animated sprite
				// and then making it transparent. Should I just use that?
				// the 'hard' way is to do it via a shader

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


	

	class PlaneInteriorScene
	{
		Person rogerInPlane = new Person(Vector2(100.0f, 400.0f), 100);
		float doorWidth = 30.0f;
		float doorHeight = 30.0f;
		Person doorInPlane = new Person(Vector2(935.0f - doorWidth, 304.0f - doorHeight) , 100);

		
	}



	class SkydivingScene
	{

		Vector2[] m_clouds;
		Person m_roger;
		//Person rogerInPlane;
		Person m_henchman;
		
		GameCamera m_camera;
		ProjectileManager m_projectileManager;
		AudioManager m_audioManager;
		float m_groundStart;
		//GameCamera gameCamera;
		
		float dt;
		// used for reloading and stuff
		int m_maxClouds;
		int m_maxBullets;
		int32 m_screenWidth;
		int32 m_screenHeight;
		Vector2 m_cameraPosition;


		public this(int _maxClouds, int maxBullets, int32 _screenWidth, int32 _screenHeight, Vector2 cameraPosition)
		{
			InitScene(_maxClouds, maxBullets, _screenWidth, _screenHeight, cameraPosition);
		}

		public void ClearAll()
		{
			delete m_clouds;
			delete m_projectileManager;
			delete m_roger;
			delete m_henchman;
			delete m_audioManager;
			delete m_camera.Position;
			delete m_camera.Velocity;
			delete m_camera.Direction;
			delete m_camera;
		}

		public ~this()
		{
			ClearAll();
		}

		public void InitScene(int maxClouds, int maxBullets, int32 _screenWidth, int32 _screenHeight, Vector2 cameraPosition)
		{
			m_clouds = new Vector2[maxClouds];
			m_maxBullets = maxBullets;

			m_projectileManager = new ProjectileManager(maxBullets);
			m_roger = new Person(Vector2(100.0f, 400.0f), 100);
			for (int i = 0; i < maxClouds; i++)
			{
				m_clouds[i].x = GetRandomValue((int32)(m_roger.Position.x) - 200, (int32)(m_roger.Position.x) + 200);
				m_clouds[i].y = GetRandomValue((int32)(m_roger.Position.y) - 200, (int32)(m_roger.Position.y) + 200);
			}

			m_henchman = new Person(Vector2(30.0f, 30.0f), 50);
			m_groundStart = 50000.0f;
			m_audioManager = new AudioManager();
			m_screenWidth = _screenWidth;
			m_screenHeight = _screenHeight;
			m_camera = new GameCamera(cameraPosition, _screenWidth, _screenHeight);
		}

		public void Reload()
		{
			ClearAll();
			InitScene(m_maxClouds, m_maxBullets, m_screenWidth, m_screenHeight, m_cameraPosition);
		}

		void DrawBloodExplosion(Vector2 originPosition, float timer)
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
				DrawCircle((int32)(originPosition.x + radius*Math.Cos(angleToUse) - m_camera.Position.x), (int32)(originPosition.y + radius*Math.Sin(angleToUse) - m_camera.Position.y), 5.0f + 20*(1.0f/(1.0f+timer)), Color.RED);
			}
		}

		public void TweakConstants()
		{
			return;
			//m_maxClouds = 1;
			//m_maxBullets = 1;
		}


		public int Update()
		{
			// have weapons fall from the sky that you can pick up?
			// or at least, have weapons able to be knocked out of people's hands mid air
			// and you can 'catch'/regather them. yeah, love that idea
			int switchScene = 0;
			//float groundStart = 5000.0f;
			dt = GetFrameTime();

			for (int i = 0; i < m_clouds.Count; i++)
			{
				Vector2 cloudPos = m_clouds[i];
				
				if (cloudPos.y <= m_roger.Position.y - m_camera.ScreenHeight)
				{
					cloudPos.y = m_roger.Position.y + m_camera.ScreenHeight;
					cloudPos.x = (float)GetRandomValue(int32(m_roger.Position.x - m_camera.ScreenWidth), int32(m_roger.Position.x + m_camera.ScreenWidth));
				}
				m_clouds[i] = cloudPos;
			}
			float terminalVelocity = 1000.0f; // what was I thinking here?
			m_roger.Direction.x = 0.0f;
			m_roger.Direction.y = 0.0f;
			float rogerSpeedAir = 500.0f;

			float enemySpeedAir = 1000.0f;

			if (m_henchman.TimerStarted)
			{
				m_henchman.DeathTimer += dt;
			}	

			// how should we move him? toward where?
			// towards the player
			// so solve the trig problem

			// this will need to be in its own function so
			// it can be applied to each enemy
			Vector2 directionToPlayer = BondMath.Matrix2.Vector2Subtract(*m_roger.Position, *m_henchman.Position);
			// i'm sure there's a fast way to get angle between two vectors using dot product

			float angleToPlayer = BondMath.Trig.RadToDeg(BondMath.Matrix2.Vector2AngleBetween(directionToPlayer, Vector2(0, 1)));
			float sign = (m_roger.Position.x < m_henchman.Position.x) ? 1.0f : -1.0f;
			angleToPlayer *= sign;
			
			// but how to get the sign of the angle?

			// dumb thing to do here is to
			// us just the x position since that's kind of the only thing we can modify

			// get desired direction

			// then get desired rotation to achieve said direction, I guess, apply it
			// 


			DrawText(scope $"the angle to the player is {angleToPlayer}", 30, 30, 30, Color.RED);

			if (m_henchman.Position.y < m_groundStart)
			{
				m_henchman.Velocity.y = (enemySpeedAir * dt);
				*m_henchman.Position += *m_henchman.Velocity;
			}
			else if (m_henchman.Health > 0)
			{
				m_henchman.Health = 0;
				if (!m_henchman.TimerStarted)
				{
					m_henchman.TimerStarted = true;
					m_henchman.AddParticleSystem(5, 50, 3.0f, 0.4f);
					m_audioManager.SoundsToPlay.Add("splat");
				}
			}
			


			


			// enemy choose direction

			if (IsKeyDown(KeyboardKey.KEY_F11))
			{
				Reload();
			}

			//rogerAirRotation = 0.0f;
			if (IsKeyDown(KeyboardKey.KEY_A))
			{
				m_roger.Direction.x = -1.0f;
				//rogerAirRotation = -45.0f;
			}
			if (IsKeyDown(KeyboardKey.KEY_D))
			{
				m_roger.Direction.x = 1.0f;
				//rogerAirRotation = 45.0f;
			}
			// this should be an enum
			bool goingUp = false;
			bool goingDown = false;
			if (IsKeyDown(KeyboardKey.KEY_W))
			{
				//rogerSpeedAir = 500.0f;
				goingUp = true;
				m_roger.Direction.y = -1.0f;
			}
			if (IsKeyDown(KeyboardKey.KEY_S))
			{
				m_roger.Direction.y = 1.0f;
				goingDown = true;
			}

			if (IsKeyDown(KeyboardKey.KEY_LEFT_SHIFT) && m_roger.Direction.x != 0.0f)
			{
				m_roger.IsRolling = true;
			}
			else
			{
				m_roger.IsRolling = false;
			}

			m_roger.IsShooting = false;
			if (IsKeyPressed(KeyboardKey.KEY_SPACE))
			{
				m_roger.IsShooting = true;
				m_audioManager.SoundsToPlay.Add("pistol_shot");
			}

			

			Matrix2.Vector2Normalize(ref *m_roger.Direction, 0.001f);
			if (m_roger.IsShooting)
			{
				// apply an impluse to the wrists that hold the gun
				// the wrists have a homeostatic thing where they want to return to a netural orientation
				// also spawn a projectile into the projectile manager
				DrawText("bang!", 10, 40, 16, Color.RED);
				// instead make a vector fr
				
				Vector2 spawnVel =  Matrix2.Vector2Scale(Vector2(Math.Cos(Trig.DegToRad((int)m_roger.AirRotation % 360)), Math.Sin(Trig.DegToRad((int)m_roger.AirRotation % 360))), -3000.0f);
				Vector2 spawnDirection = Matrix2.Vector2Normalized(spawnVel,0.001f);
				Vector2 spawnPos = *m_roger.Position + Matrix2.Vector2Scale(spawnDirection, 100.0f);
				// draw something at the spawn position to figure out why it's behaving weird
				//DrawCircle((int32)(spawnPos.x - camera.Position.x), (int32)(spawnPos.y - camera.Position.y), 5.0f, Color.GOLD);
				m_projectileManager.AddProjectile(spawnPos, spawnVel, 25, 50.0f);
			}
			float rotationSpeed = 150.0f;
			// this hsould have some acceleration to it too
			
			float rogerAirMotion = Math.Sin(Trig.DegToRad((int)m_roger.AirRotation % 360));
			float rogerAirMotionUp = Math.Cos(Trig.DegToRad((int)m_roger.AirRotation % 360));
			//float rogerAirMotionDown = Math.Sin(Trig.DegToRad((int)m_roger.AirRotation % 360));
			String airMotionText = scope $"AirMotion = {rogerAirMotion}";
			String airRotationText = scope $"From air rotation = {m_roger.AirRotation}";
			DrawText(airMotionText, 10, 10, 16, Color.RED);
			DrawText(airRotationText, 10, 20, 16, Color.RED);	
			

			// need to apply some friction
			Vector2 rogerFriction = Matrix2.Vector2Scale(*m_roger.Velocity, -0.8f);
			//float armPerSecond = 10.0f;
			//armOscilator += dt;
			//armAngleToOscilate = Math.Sin(armOscilator*2*Math.PI_f / armPerSecond) * 10.0f;
			//float armAngleToOscilate = 5.0f;

			// TODO (Cooper): make a general 'person' update velocity function here
			// that way I can avoid re-working a ton of code
			
			if (m_roger.TimerStarted)
			{
				m_roger.DeathTimer += dt;
			}
			// (TODO) : use force vectors
			if (m_roger.Position.y < m_groundStart) // i.e we are in the air
				// there is such thing as terminal velocity
				// the maximum speed attainable in the air
			{
				float offset = 0.00f;
				if (goingUp)
				{
					offset = -500.0f * (rogerAirMotionUp);
				}
				if (goingDown)
				{
					offset = 500.0f * (rogerAirMotionUp);
				}

				float fallingSpeedToUse = terminalVelocity + offset;
				DrawText(scope $"the falling speed is {fallingSpeedToUse}", 50, 200, 20, Color.RED);
				
				m_roger.Position.y += (terminalVelocity + offset) * dt; // this is our base falling rate
				if (!m_roger.IsRolling)
				{
					m_roger.AirRotation += m_roger.Direction.x * dt * rotationSpeed;					
					m_roger.Velocity.x += rogerAirMotion * dt * rogerSpeedAir;
					// this shouldn't be active when he's on the ground
					//roger.Velocity.y += roger.Direction.y * dt * rogerSpeedAir;

					//roger.Velocity.y += (10.0f * dt * rogerAirMotionUp);

					m_roger.Velocity.x += rogerFriction.x*dt;
					//roger.Velocity.y += rogerFriction.y*dt;
					m_roger.Position.x += (m_roger.Velocity.x) * dt;
					m_roger.Position.y += (m_roger.Velocity.y) * dt;
					//roger.Position.y += terminalVelocity * dt;
				}
				else
				{
					m_roger.AirRotation += m_roger.Direction.x * dt * rotationSpeed * 10.0f;
					//roger.Velocity.x += rogerAirMotion * dt * rogerSpeedAir;
					// this shouldn't be active when he's on the ground
					m_roger.Velocity.y += m_roger.Direction.y * dt * rogerSpeedAir;

					m_roger.Velocity.y += (10.0f * dt * rogerAirMotionUp);

					m_roger.Velocity.x += rogerFriction.x*dt;
					m_roger.Velocity.y += rogerFriction.y*dt;
					m_roger.Position.x += (m_roger.Velocity.x) * dt;
					m_roger.Position.y += (m_roger.Velocity.y) * dt;
					//roger.Position.y += terminalVelocity * dt;
				}
				
			}
			else if (m_roger.Health > 0)
			{
				m_roger.Health = 0;
				if (!m_roger.TimerStarted)
				{
					m_roger.TimerStarted = true;
					// and spawn particles
					m_roger.AddParticleSystem(10, 50, 3.0f, 0.2f);
					m_audioManager.SoundsToPlay.Add("splat");
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

						
			// would it be better to have a velocity for the camera?			
			
			float cameraAccelX = 0.0f;
			float cameraAccelY = 0.0f;
			float halfScreenWidth = m_camera.ScreenWidth* 0.5f;
			float deadzoneX = m_camera.ScreenWidth* 0.25f;

			float halfScreenHeight = m_camera.ScreenHeight* 0.5f;
			float deadzoneY = m_camera.ScreenHeight* 0.25f;

			float cameraCenterX = m_camera.Position.x + halfScreenWidth;
			float cameraCenterY = m_camera.Position.y + halfScreenHeight;
			float deltaX = m_roger.Position.x - cameraCenterX; // distance from center
			float deltaY = m_roger.Position.y - cameraCenterY; // distance from center
			float stretchX = 0.0f; // how stretched is the spring?
			float stretchY = 0.0f; // how stretched is the spring?

			if (deltaX > deadzoneX) {
				stretchX = deltaX - deadzoneX;
			} else if (deltaX < -deadzoneX) {
				stretchX = deltaX + deadzoneX;
			}

			if (deltaY > deadzoneY) {
				stretchY = deltaY - deadzoneY;
			} else if (deltaY < -deadzoneY) {
				stretchY = deltaY + deadzoneY;
			}

			float k = 50.0f;
			float c = 2.0f * Math.Sqrt(k);

			float ky = 1000.0f;
			float cy = 2.0f * Math.Sqrt(ky);

			cameraAccelX = (k*stretchX - c * m_camera.Velocity.x);

			cameraAccelY = (ky*stretchY - cy * m_camera.Velocity.y);

			m_camera.Velocity.y += cameraAccelY * dt;
			m_camera.Position.y += m_camera.Velocity.y * dt;

			m_camera.Velocity.x += cameraAccelX * dt;
			m_camera.Position.x += m_camera.Velocity.x * dt;
						


			m_projectileManager.UpdateProjectiles(dt, m_henchman, m_audioManager.SoundsToPlay);

			if (m_henchman.Health <= 0 && !m_henchman.TimerStarted)
			{
				m_henchman.TimerStarted = true;
				m_henchman.AddParticleSystem(5, 50, 3.0f, 0.4f);
			}
			

			

			return switchScene;


		}

		public void DrawParticleSystemPerson(Person person, GameCamera gameCamera, float dt)
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

		public void Render(GameResources gameResources)
		{
			BeginDrawing();

			float flattenTime = 0.05f;

			ClearBackground(.(50, 120, 250, 255)); // sky blue

			// then draw in some mountains
			float rogerFromGround = Math.Max(m_groundStart - m_roger.Position.y, 0.0f);
			float horizonNorm = (1.0f - (rogerFromGround / m_groundStart));
			int32 horizonHeight = (int32)(horizonNorm * 220.0f);
			int32 horizonHeightToDraw = (int32)gameResources.screenHeight/2 - (int32)(horizonNorm * 220.0f);
			int32 horizonStart = (int32)(gameResources.screenHeight - horizonHeight);
			Color groundColor = Color(200, 100, 10, 255);
			Color groundColorEnd = Color(150, 50, 10, 255);
			DrawRectangleGradientV(0, horizonStart, (int32)gameResources.screenWidth, horizonHeightToDraw, groundColor, groundColorEnd);
			// DrawRectangle(0, horizonStart, (int32)gameResources.screenWidth, (int32)gameResources.screenHeight, groundColor);

			// we should draw these mountains slightly parallaxed
			float mountainParallax = m_camera.Position.x / 50.0f;
			float mountainCountOffset = 0.0f;
			// TODO make a center of the triangle to work with so it's more mountainlike?
			DrawTriangle(Vector2(30.0f - mountainParallax, horizonStart - 20.0f), Vector2(10.0f - mountainParallax, horizonStart), Vector2(70.0f - mountainParallax, horizonStart), Color.BROWN);
			mountainCountOffset += 50.0f;
			float mountainHeight = 50.0f;
			DrawTriangle(Vector2(30.0f + mountainCountOffset - mountainParallax, horizonStart - mountainHeight), Vector2(10.0f + mountainCountOffset - mountainParallax, horizonStart), Vector2(70.0f + mountainCountOffset - mountainParallax, horizonStart), Color.BROWN);
			mountainHeight = 40.0f;
			mountainCountOffset += 50.0f;
			DrawTriangle(Vector2(30.0f + mountainCountOffset - mountainParallax, horizonStart - mountainHeight), Vector2(10.0f + mountainCountOffset - mountainParallax, horizonStart), Vector2(70.0f + mountainCountOffset - mountainParallax, horizonStart), Color.BROWN);

			mountainCountOffset += 250.0f;			
			DrawTriangle(Vector2(40.0f + mountainCountOffset - mountainParallax, horizonStart - mountainHeight), Vector2(10.0f + mountainCountOffset - mountainParallax, horizonStart), Vector2(65.0f + mountainCountOffset - mountainParallax, horizonStart), Color.BROWN);
			mountainHeight = 15.0f;
			mountainCountOffset += 250.0f;
			DrawTriangle(Vector2(17.0f + mountainCountOffset - mountainParallax, horizonStart - mountainHeight), Vector2(10.0f + mountainCountOffset - mountainParallax, horizonStart), Vector2(32.0f + mountainCountOffset - mountainParallax, horizonStart), Color.BROWN);

			

			for (Vector2 cloud in m_clouds)
			{
			 		//cloud.x = cloud.x - cameraPosition.x;
			 		DrawTextureEx(gameResources.cloudTexture, Matrix2.Vector2Subtract(cloud, *m_camera.Position), 0.0f, 5.0f, Color.WHITE);
			 }

			// 	draw the ground when it's in frame, or just draw it offscreen constantly
			// start by the dumb way
			DrawRectangle(0, (int32)(m_groundStart - m_camera.Position.y), m_screenWidth, m_screenHeight, groundColorEnd);

			//DrawTextureEx(gameResources.rogerSkyDiveTexture, Matrix2.Vector2Subtract(*roger.Position, *camera.Position), roger.AirRotation, 3.0f, Color.WHITE);
			if (m_roger.Health > 0)
			{
			 		DrawTexturePro(gameResources.rogerSkyDiveTexture, Rectangle(0.0f, 0.0f, 128.0f, 128.0f), Rectangle(m_roger.Position.x - m_camera.Position.x, m_roger.Position.y - m_camera.Position.y, 1.5f*128.0f, 1.5f*128.0f),Vector2(1.5f*64.0f, 1.5f*64.0f), m_roger.AirRotation, Color.WHITE);
			}
			else
			{
					// prototype one
					//DrawBloodExplosion(*roger.Position, roger.DeathTimer);
					float stretchAmount = Math.Min(m_roger.DeathTimer / flattenTime, 1.0f);
					float stretchDist = 80.0f;
					float flattenAmount = 1.0f - Math.Min(m_roger.DeathTimer / flattenTime, 1.0f);
					float heightToDraw = 1.5f*flattenAmount*128.0f;
					//float fullHeight = 1.5f*128.0f;
					//float offsetAmount = fullHeight - heightToDraw;
					DrawTexturePro(gameResources.rogerSkyDiveTexture, Rectangle(0.0f, 0.0f, 128.0f, 128.0f), Rectangle(m_roger.Position.x - m_camera.Position.x, m_roger.Position.y - m_camera.Position.y, 1.5f*128.0f + stretchAmount*stretchDist, heightToDraw),Vector2(1.5f*64.0f, heightToDraw/2.0f), m_roger.AirRotation, Color.RED);

					//DrawTexturePro(gameResources.rogerSkyDiveTexture, Rectangle(0.0f, 0.0f, 128.0f, 128.0f), Rectangle(roger.Position.x - camera.Position.x, roger.Position.y - camera.Position.y, 128.0f, 128.0f),Vector2(64.0f, 64.0f), roger.AirRotation, Color.WHITE);
					
					m_roger.DrawParticleSystem(m_camera, dt, 2200.0f, m_groundStart);
					//DrawParticleSystemPerson(roger, camera, dt);
				}


				

            	//	think about the rotation point
				//	but also think like, actual skeletal system


            	//	TODO: make these centered
				if (m_henchman.Health > 0)
				{
					DrawTexturePro(gameResources.henchmanTexture, Rectangle(0.0f, 0.0f, 128.0f, 128.0f), Rectangle(m_henchman.Position.x - m_camera.Position.x, m_henchman.Position.y - m_camera.Position.y, 1.5f*128.0f, 1.5f*128.0f),Vector2(1.5f*64.0f, 1.5f*64.0f), m_henchman.AirRotation, Color.WHITE);
					//DrawTexturePro(gameResources.henchmanTexture, *henchman.Position - *camera.Position, 0.0f, 2.0f, Color.WHITE);
				}
				else
				{
					// we haven't made the particle system yet
					float stretchAmount = Math.Min(m_roger.DeathTimer / flattenTime, 1.0f);
					float stretchDist = 80.0f;
					float flattenAmount = 1.0f - Math.Min(m_henchman.DeathTimer / flattenTime, 1.0f);
					float heightToDraw = 1.5f*flattenAmount*128.0f;
					//float fullHeight = 1.5f*128.0f;
					//float offsetAmount = fullHeight - heightToDraw;
					DrawTexturePro(gameResources.henchmanTexture, Rectangle(0.0f, 0.0f, 128.0f, 128.0f), Rectangle(m_henchman.Position.x - m_camera.Position.x, m_henchman.Position.y - m_camera.Position.y, 1.5f*128.0f + stretchAmount*stretchDist, heightToDraw),Vector2(1.5f*64.0f, heightToDraw/2.0f), m_henchman.AirRotation, Color.RED);
					m_henchman.DrawParticleSystem(m_camera, dt, 2200.0f, m_groundStart);
					//DrawParticleSystemPerson(henchman, gameCamera, dt);
					//DrawBloodExplosion(*henchman.Position, henchman.DeathTimer);
				}
				m_projectileManager.RenderProjectiles(m_camera, dt);
				EndDrawing();
				

		}
	}
}
