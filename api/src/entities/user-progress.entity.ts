import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { User } from './user.entity';
import { Lesson } from './lesson.entity';

@Entity('user_progress')
export class UserProgress {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  userId: number;

  @ManyToOne(() => User, (user) => user.progress, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'userId' })
  user: User;

  @Column()
  lessonId: number;

  @ManyToOne(() => Lesson, (lesson) => lesson.progress, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'lessonId' })
  lesson: Lesson;

  @Column({ default: 'in_progress' }) // 'in_progress' | 'completed'
  status: string;

  @Column({ default: 0 })
  score: number;

  @Column({ name: 'completed_at', nullable: true })
  completedAt: Date;

  @CreateDateColumn({ name: 'started_at' })
  startedAt: Date;

  @Column({ name: 'is_favorite', default: false })
  isFavorite: boolean;

  @Column({ name: 'review_count', default: 0 })
  reviewCount: number;

  @Column({ name: 'best_score', type: 'float', default: 0 })
  bestScore: number; // For pronunciation scoring 0-100

  @Column({ name: 'grammar_checks', default: 0 })
  grammarChecks: number;

  @CreateDateColumn({ name: 'first_seen_at' })
  firstSeenAt: Date;

  @Column({ name: 'last_reviewed_at', type: 'timestamp', nullable: true })
  lastReviewedAt: Date;
}
