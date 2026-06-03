import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { Lesson } from './lesson.entity';

@Entity('quiz_questions')
export class QuizQuestion {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  lessonId: number;

  @ManyToOne(() => Lesson, (lesson) => lesson.quizQuestions, {
    onDelete: 'CASCADE',
  })
  @JoinColumn({ name: 'lessonId' })
  lesson: Lesson;

  @Column()
  questionType: string; // 'mcq' | 'translate' | 'audio'

  @Column('text')
  questionText: string;

  @Column('jsonb', { nullable: true })
  options: string[];

  @Column()
  correctAnswer: string;
}
