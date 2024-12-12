using System;
using System.Collections;
using static raylib_beef.Raylib;
using raylib_beef.Types;
using raylib_beef.Enums;
using BondMath;

using Game;

namespace Entities
{
	



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

	class AudioManager
	{
		public List<String> SoundsToPlay;

		public this()
		{

			SoundsToPlay = new List<String>();
		}

		public ~this()
		{
			for (String sound in SoundsToPlay)
			{
				delete sound;
			}
			delete SoundsToPlay;
		}

	}

	class ProjectileManager
	{
		public int SpawnedAmount {get;set;}
		public Projectile[] Projectiles {get;set;}
		public int MaxProjectiles {get;set;}

		public this(int maxProjectiles)
		{
			SpawnedAmount = 0;
			MaxProjectiles = maxProjectiles;
			Projectiles = new Projectile[MaxProjectiles];
			for (int i = 0; i < MaxProjectiles ; i++)
			{
				Projectile projectileToAdd = new Projectile(Vector2(0.0f, 0.0f));
				Projectiles[i] = projectileToAdd;
			}
		}

		public ~this()
		{
			for (int i = 0; i < MaxProjectiles; i++)
			{
				delete Projectiles[i];
			}
			delete Projectiles;
		}

		public bool AddProjectile(Vector2 position, Vector2 velocity, int damage, float lifetime)
		{
			bool suceeded = false;
			if (SpawnedAmount == MaxProjectiles)
			{
				return suceeded;
			}

			for (int i = 0; i < MaxProjectiles; i++)
			{
				if (!Projectiles[i].Active)
				{
					Projectiles[i].Active = true;
					Projectiles[i].Position = position;
					Projectiles[i].Velocity = velocity;
					Projectiles[i].Damage = damage;
					Projectiles[i].Lifetime = lifetime;
					SpawnedAmount++;
					suceeded = true;
					break;
				}
			}
			return suceeded;
		}

		public void UpdateProjectiles(float dt, Person person, List<String> soundsToPlay) // make array of peopple
		{

			// thing to do here would be to first store the position of each person
			// as potential hitboxes with ids occupying it
			// then for each projectile,
			// do the lookup of that position and apply damage to entities at that id
			// *then*
			// for each projectile, see
			
			for (int i = 0; i < MaxProjectiles; i++)
			{
				if (Projectiles[i].Active)
				{
					bool shouldDespawn = false;
					Projectiles[i].Timer += dt;
					if (Projectiles[i].Timer >= Projectiles[i].Lifetime)
					{
						shouldDespawn = true;
						//Projectiles[i].Active = false;
						//SpawnedAmount--;
						//continue;
					}

					
					Projectiles[i].Position = Matrix2.Vector2Add(Projectiles[i].Position, Matrix2.Vector2Scale(Projectiles[i].Velocity, dt));

					//for (Person person in people)
					//{
					float hitbox = 35.0f;
					if (Matrix2.Vector2Distance(Projectiles[i].Position, *(person).Position) < hitbox)
					{
							(person).Health -= Projectiles[i].Damage;
							soundsToPlay.Add("gun_hit");
							// also add a gore effect to spawn, or mini particle system or whatever
							shouldDespawn = true;
							//break;
					}
					//}


					if (shouldDespawn)
					{
						Projectiles[i].Active = false;
						SpawnedAmount--;
					}
					
				}
			}
		}

		public void RenderProjectiles(GameCamera gameCamera, float dt)
		{
			for (int i = 0; i < MaxProjectiles; i++)
			{
				if (Projectiles[i].Active)
				{
					DrawCircle((int32)(Projectiles[i].Position.x - gameCamera.Position.x), (int32)(Projectiles[i].Position.y - gameCamera.Position.y), 5.0f,  Color.DARKGRAY);
					
					
				}
			}
		}


	}

	class Projectile
	{
		public Vector2 Position {get; set;}
		public Vector2 Velocity {get; set;}
		public int Damage {get;set;}
		public bool Active {get;set;}
		public float Timer {get;set;}
		public float Lifetime {get;set;}
		public this(Vector2 position, int damage = 0, float lifetime = 0.0f)
		{
			Position = Vector2(position.x, position.y);
			Damage = damage;
			Active = false;
			Timer = 0.0f;
			Lifetime = lifetime;
		}
	}

	class Person
	{

		public Vector2 *Position {get; set;}

		public int Health {get; set;}

		public Vector2 *Direction {get; set;}

		public Vector2 *Velocity {get; set;}

		public float DecisionTimer {get; set;}

		public float AirRotation {get; set;}

		public bool TimerStarted {get;set;}
		public float DeathTimer = 0.0f;
		public float ShotTimer = 0.0f;

		public Skeleton *BaseSkeleton {get;set;}
		public Skeleton OffsetSkeleton {get;set;}

		public Particle[] Particles {get;set;} = null;

		public bool IsRolling {get;set;} = false;
		public bool IsShooting {get;set;} = false;

		
		public this(Vector2 position, int health)
		{
			Position = new Vector2(position.x, position.y);
			Health = health;
			Direction = new Vector2(0.0f, 0.0f);
			Velocity = new Vector2(0.0f, 0.0f);
			DecisionTimer = 0.0f;
			AirRotation = 0.0f;
			TimerStarted = false;
			DeathTimer = 0.0f;
			//OffsetSkeleton = new Skeleton();
		}

		public ~this()
		{
			delete Direction;
			delete Position;
			delete Velocity;
			//delete Particles;
			if (Particles != null)
			{
				for (var particle in Particles)
				{
					delete particle;
				}
				delete Particles;
			}
			
			
			//delete this;
		}

		public void AddParticleSystem(int waves, int particlesPerWave, float totalDuration, float emissionSpeed)
		{
			int particleCount = waves * particlesPerWave;
			this.Particles = new Particle[particleCount];
			
			int wavesAdded = 0;
			for (int i = 0; i < waves; i++)
			{
				for (int j = 0; j < particlesPerWave; j++)
				{
					Particle particleToAdd = new Particle();
					float lerpedTimeValue = (float)i / (float) waves;
					float lerpedPositionValue = (float)j / (float) particlesPerWave;
					particleToAdd.Position = Vector2(this.Position.x, this.Position.y);
					particleToAdd.LifetimeStart = emissionSpeed * lerpedTimeValue;
					particleToAdd.LifetimeEnd = emissionSpeed * lerpedTimeValue + totalDuration;
					float lerpedAngle = Math.PI_f * lerpedPositionValue + Math.PI_f + (float)(GetRandomValue(1,5));
					particleToAdd.Velocity = Vector2(Math.Cos(lerpedAngle), Math.Sin(lerpedAngle));
					if (particleToAdd.Velocity.y > 0.0f)
					{
						particleToAdd.Velocity = Matrix2.Vector2Scale(particleToAdd.Velocity, -1.0f);
					}
					float initialSpeed = 100f + (float)(100.0f*GetRandomValue(0, 100));
					particleToAdd.Velocity = Matrix2.Vector2Scale(particleToAdd.Velocity, initialSpeed);
					this.Particles[wavesAdded++] = particleToAdd;
				}
			}
		}

		public void DrawParticleSystem(GameCamera gameCamera, float dt, float gravityConstant, float groundLoc)
		{
			for (int i = 0; i < this.Particles.Count; i++)
			{
				Particle particle = this.Particles[i];
				if (this.DeathTimer >= particle.LifetimeStart &&
					this.DeathTimer <= particle.LifetimeEnd &&
					(particle.Position.y <= groundLoc) || (particle.Velocity.y < 0)
					)
				{
					
					Vector2 gravity = Vector2(0.0f, gravityConstant*dt);
					particle.Velocity += gravity;
					particle.Position += Matrix2.Vector2Scale(particle.Velocity, dt);
					DrawCircle((int32)(particle.Position.x - gameCamera.Position.x), (int32)(particle.Position.y - gameCamera.Position.y), 3.0f, Color.RED);
					this.Particles[i] = particle;
					
					
				}
				else if (particle.Position.y >= groundLoc)
				{
					DrawCircle((int32)(particle.Position.x - gameCamera.Position.x), (int32)(particle.Position.y - gameCamera.Position.y), 3.0f, Color.RED);
					//float poolingTime = 1.0f;
					//float timeSinceGround  = Math.Max(Math.Min(this.DeathTimer - particle.LifetimeEnd, poolingTime), 0.1f);
					//float lerped = timeSinceGround / poolingTime;
					
					//DrawEllipse((int32)(particle.Position.x - gameCamera.Position.x), (int32)(particle.Position.y - gameCamera.Position.y), 20.0f * lerped, 10.0f * lerped, Color.RED);
				}
			}
		}
	}

	class ParticleSystem
	{
        public bool IsActive = false;
		Particle[] Particles = null;
        // we should probably create each one as a max amount?
        // and then just track active/inactive
        float ParticleTimer = 0.0f;
        

        public this(Vector2 pos, int waves, int particlesPerWave, float totalDuration, float emissionSpeed, float initialSpeedBase, float randomScale, int32 randomBound)
        {
            IsActive = true;
            AddParticleSystem(pos, waves, particlesPerWave, totalDuration, emissionSpeed, initialSpeedBase, randomScale,  randomBound);
        }

        public ~this()
        {
            if (Particles != null)
            {
                for (var particle in Particles)
                {
                    delete particle;
                }
                delete Particles;
                Particles = null;
            }
        }

        public void AddParticleSystem(Vector2 pos, int waves, int particlesPerWave, float totalDuration, float emissionSpeed, float initialSpeedBase, float randomScale, int32 randomBound)
		{
			int particleCount = waves * particlesPerWave;
            ParticleTimer = 0.0f;

            if (this.Particles != null)
            {
                // will have to immediately change this
                // to support multiple particle systems
                // we could just do a flat array of them
                for (var particle in Particles)
                {
                    delete particle;
                }
                delete Particles;
                Particles = null;                
            }
			this.Particles = new Particle[particleCount];
			
			int particlesAdded = 0;
			for (int i = 0; i < waves; i++)
			{
				for (int j = 0; j < particlesPerWave; j++)
				{
					Particle particleToAdd = new Particle();
					float lerpedTimeValue = (float)i / (float) waves;
					float lerpedPositionValue = (float)j / (float) particlesPerWave;
					particleToAdd.Position = Vector2(pos.x, pos.y);
					particleToAdd.LifetimeStart = emissionSpeed * lerpedTimeValue;
					particleToAdd.LifetimeEnd = emissionSpeed * lerpedTimeValue + totalDuration;
					float lerpedAngle = Math.PI_f * lerpedPositionValue + Math.PI_f + (float)(GetRandomValue(1,5));
					particleToAdd.Velocity = Vector2(Math.Cos(lerpedAngle), Math.Sin(lerpedAngle));
					if (particleToAdd.Velocity.y > 0.0f)
					{
						particleToAdd.Velocity = Matrix2.Vector2Scale(particleToAdd.Velocity, -1.0f);
					}
					float initialSpeed = initialSpeedBase + (float)(randomScale*GetRandomValue(1, randomBound));
					particleToAdd.Velocity = Matrix2.Vector2Scale(particleToAdd.Velocity, initialSpeed);
					this.Particles[particlesAdded++] = particleToAdd;
				}
			}
		}

        public void SetExistingParticleSystem(Vector2 pos, int waves, int particlesPerWave, float totalDuration, float emissionSpeed, float initialSpeedBase, float randomScale, int32 randomBound)
		{
			int particleCount = waves * particlesPerWave;
            ParticleTimer = 0.0f;						
			int particlesUpdated = 0;
			for (int i = 0; i < waves; i++)
			{
				for (int j = 0; j < particlesPerWave; j++)
				{
					Particle particleToUpdate = Particles[particlesUpdated];
					float lerpedTimeValue = (float)i / (float) waves;
					float lerpedPositionValue = (float)j / (float) particlesPerWave;
					particleToUpdate.Position = Vector2(pos.x, pos.y);
					particleToUpdate.LifetimeStart = emissionSpeed * lerpedTimeValue;
					particleToUpdate.LifetimeEnd = emissionSpeed * lerpedTimeValue + totalDuration;
					float lerpedAngle = Math.PI_f * lerpedPositionValue + Math.PI_f + (float)(GetRandomValue(1,5));
					particleToUpdate.Velocity = Vector2(Math.Cos(lerpedAngle), Math.Sin(lerpedAngle));
					if (particleToUpdate.Velocity.y > 0.0f)
					{
						particleToUpdate.Velocity = Matrix2.Vector2Scale(particleToUpdate.Velocity, -1.0f);
					}
					float initialSpeed = initialSpeedBase + (float)(randomScale*GetRandomValue(0, randomBound));
					particleToUpdate.Velocity = Matrix2.Vector2Scale(particleToUpdate.Velocity, initialSpeed);
					this.Particles[particlesUpdated++] = particleToUpdate;
				}
			}
		}

        public void UpdateParticleSystem(float dt)
        {
            float gravityConstant = 9.5f;
            if (this.Particles == null)
            {
                return;
            }
            bool foundActiveParticle = false;

            ParticleTimer += dt;
            for (int i = 0; i < this.Particles.Count; i++)
			{
				Particle particle = this.Particles[i];
				if (ParticleTimer >= particle.LifetimeStart &&
					ParticleTimer <= particle.LifetimeEnd &&
					(particle.Velocity.y < 0)
					)
				{					
					Vector2 gravity = Vector2(0.0f, gravityConstant*dt);
					particle.Velocity += gravity;
					particle.Position += Matrix2.Vector2Scale(particle.Velocity, dt);
					this.Particles[i] = particle;
                    foundActiveParticle = true;
				}

			}
            if (!foundActiveParticle)
            {
                IsActive = false;
            }
        }

        public void DrawParticleSystem()
		{
            // TODO: store some flag about if all particles are finished, so you have early return
            // or no function call at all
            if (!IsActive)
            {
                return;
            }
            if (this.Particles == null)
            {
                return;
            }

            // could do options in here
            
			for (int i = 0; i < this.Particles.Count; i++)
			{
				Particle particle = this.Particles[i];
				if (ParticleTimer >= particle.LifetimeStart &&
					ParticleTimer <= particle.LifetimeEnd					
					)
				{
                    // probably want to parametrize the color, size, transparency
                    float alphaToDraw = 255.0f*(1.0f - (ParticleTimer - particle.LifetimeStart) / (particle.LifetimeEnd - particle.LifetimeStart));
                    Color toDraw = Color(150, 150, 150, (uint8)alphaToDraw);

					DrawCircle((int32)(particle.Position.x), (int32)(particle.Position.y), 3.0f, toDraw);										
				}

			}
		}

        

	}

	class Particle
	{
		public Vector2 Position {get;set;}
		public Vector2 Velocity {get;set;}
		public Vector2 Acceleration {get;set;}
		public float LifetimeStart {get;set;}
		public float LifetimeEnd {get;set;}

		public this()
		{
			Position = Vector2(0.0f, 0.0f);
			Velocity = Vector2(0.0f, 0.0f);
			Acceleration = Vector2(0.0f, 0.0f);
			LifetimeStart = 0.0f;
			LifetimeEnd = 0.0f;
		}

		public this(Vector2 position, float lifetimeStart, float lifetimeEnd)
		{
			Position = position;
			Velocity = Vector2(0.0f, 0.0f);
			Acceleration = Vector2(0.0f, 0.0f);
			LifetimeStart = lifetimeStart;
			LifetimeEnd = lifetimeEnd;
		}
		

	}

	class GameCamera
	{
		public Vector2 *Position {get;set;}

		public int32 ScreenWidth {get;set;}
		public int32 ScreenHeight {get;set;}

		public this(Vector2 position, int32 screenWidth, int32 screenHeight)
		{
			Position = new Vector2(position.x, position.y);
			ScreenWidth = screenWidth;
			ScreenHeight = screenHeight;

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

		public this()
		{
			Torso = Vector2(0.0f, 0.0f);
			Head = Vector2(0.0f, 0.0f);
			UpperArm = Vector2(0.0f, 0.0f);
			LowerArm = Vector2(0.0f, 0.0f);
			UpperLeg = Vector2(0.0f, 0.0f);
			LowerLeg = Vector2(0.0f, 0.0f);
		}

		
	}

	class Bone
	{
		public Vector2 Position {get;set;}
		public float Rotation {get;set;}
		public List<Bone> Children = new List<Bone>(); // maybe this should be an array? but

		public this(Vector2 position, float rotation, List<Bone> children)
		{
			Position = position;
			Rotation = rotation;
			Children = children;
		}

	}
}
