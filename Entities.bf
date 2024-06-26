using System;
using System.Collections;
using static raylib_beef.Raylib;
using raylib_beef.Types;
using raylib_beef.Enums;
using BondMath;

namespace Entities
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

	class ProjectileManager
	{
		int SpawnedAmount {get;set;}
		Projectile[] Projectiles {get;set;}
		int MaxProjectiles {get;set;}

		public this(int maxProjectiles)
		{
			SpawnedAmount = 0;
			MaxProjectiles = maxProjectiles;
			Projectiles = new Projectile[MaxProjectiles];
		}

	}

	class Projectile
	{
		public Vector2 Position {get; set;}
		public Vector2 Velocity {get; set;}
		public int Damage {get;set;}

		public this(Vector2 position, int damage)
		{
			Position = Vector2(position.x, position.y);
			Damage = damage;
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

		public Skeleton *BaseSkeleton {get;set;}
		public Skeleton OffsetSkeleton {get;set;}

		public Particle[] Particles {get;set;} = null;

		public bool IsRolling {get;set;} = false;

		
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
		public Particle[] Particles {get;set;}

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
