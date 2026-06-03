import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  JoinColumn,
  OneToMany,
} from 'typeorm';
import { CourseLevel } from './course-level.entity';
import { Vocabulary } from './vocabulary.entity';
import { Grammar } from './grammar.entity';
import { QuizQuestion } from './quiz-question.entity';
import { UserProgress } from './user-progress.entity';

@Entity('lessons')
export class Lesson {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  courseLevelId: number;

  @ManyToOne(() => CourseLevel, (level) => level.lessons, {
    onDelete: 'CASCADE',
  })
  @JoinColumn({ name: 'courseLevelId' })
  courseLevel: CourseLevel;

  @Column()
  title: string; // e.g. "Chủ đề 1: Ăn uống"

  @Column({ nullable: true })
  description: string;

  @Column({ name: 'order_index', default: 1 })
  orderIndex: number;

  @OneToMany(() => Vocabulary, (vocab) => vocab.lesson)
  vocabularies: Vocabulary[];

  @OneToMany(() => Grammar, (grammar) => grammar.lesson)
  grammars: Grammar[];

  @OneToMany(() => QuizQuestion, (question) => question.lesson)
  quizQuestions: QuizQuestion[];

  @OneToMany(() => UserProgress, (progress) => progress.lesson)
  progress: UserProgress[];
}
