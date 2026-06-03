import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  CreateDateColumn,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { Lesson } from './lesson.entity';

@Entity('grammar')
export class Grammar {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ nullable: true })
  lessonId: number;

  @ManyToOne(() => Lesson, (lesson) => lesson.grammars, {
    onDelete: 'SET NULL',
  })
  @JoinColumn({ name: 'lessonId' })
  lesson: Lesson;

  @Column()
  level: string; // 'HSK 1', 'HSK 2', etc.

  @Column()
  title: string;

  @Column('text')
  explanation: string;

  @Column({ type: 'jsonb', nullable: true })
  examples: object[];

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;
}
